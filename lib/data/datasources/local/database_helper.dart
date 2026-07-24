// lib/data/datasources/local/database_helper.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';

/// The single central data hub for all local persistence.
/// All query, aggregation, and CRUD logic lives here.
/// Repositories and providers call these methods directly.
class DatabaseHelper {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ─── Hive box names ───────────────────────────────────────────────────────
  static const _gemstonesBoxName = 'gemstones';

  // ─── Secure storage for AES cipher key ───────────────────────────────────
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'gemhub_hive_aes_key_v1';

  // ─── Lazy box reference ───────────────────────────────────────────────────
  Box<Map>? _gemstonesBox;

  // ─── Public initialiser (call once in main.dart) ──────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  // ─── Backup / Restore helpers ─────────────────────────────────────────────

  /// Flush pending writes, close the Hive box, and clear the cached reference
  /// so the file is no longer locked. Call this BEFORE overwriting the .hive
  /// file on disk (e.g. during a restore).
  Future<void> closeBox() async {
    if (_gemstonesBox != null && _gemstonesBox!.isOpen) {
      await _gemstonesBox!.flush();
      await _gemstonesBox!.close();
    }
    _gemstonesBox = null;
  }

  /// Re-open the Hive box after a restore so subsequent reads use the freshly
  /// extracted file. Throws if the file cannot be opened (e.g. wrong key /
  /// corrupt archive), which lets the caller surface the error.
  Future<void> reopenBox() async {
    // Ensure any stale reference is cleared first
    if (_gemstonesBox != null && _gemstonesBox!.isOpen) {
      await _gemstonesBox!.close();
    }
    _gemstonesBox = null;
    // This will re-read the key from secure storage and open the box
    await _box;
  }

  // ─── Internal: get or open the gemstones box (encrypted) ─────────────────
  Future<Box<Map>> get _box async {
    if (_gemstonesBox != null && _gemstonesBox!.isOpen) return _gemstonesBox!;
    final cipher = HiveAesCipher(await _getAesKey());
    _gemstonesBox = await Hive.openBox<Map>(_gemstonesBoxName, encryptionCipher: cipher);
    return _gemstonesBox!;
  }

  // ─── Internal: generate / retrieve 32-byte AES key ───────────────────────
  Future<List<int>> _getAesKey() async {
    String? stored = await _storage.read(key: _keyName);
    if (stored == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      stored = base64Url.encode(bytes);
      await _storage.write(key: _keyName, value: stored);
    }
    return base64Url.decode(stored);
  }

  // ─── Shared cost calculator (mirrors SQL COALESCE sums) ──────────────────
  double _calcExpenses(GemstoneModel g) =>
      g.buyingPrice +
      g.treatmentCost +
      g.recutCost +
      g.otherProcessingCost +
      g.transportCost +
      g.otherCost +
      g.cuttingCost +
      g.heatCost +
      g.certificateFees;

  double _calcRevenue(GemstoneModel g) =>
      g.actualSoldPrice > 0 ? g.actualSoldPrice : 0.0;

  // ─── Internal: parse yyyy-MM-dd string → fractional Julian day ───────────
  double? _julianDay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final d = DateTime.parse(dateStr);
      // Julian Day Number formula
      final a = (14 - d.month) ~/ 12;
      final y = d.year + 4800 - a;
      final m = d.month + 12 * a - 3;
      final jdn =
          d.day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
      return jdn.toDouble();
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VARIETY  (replaced the gem_varieties table — sourced from enum directly)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<String>> getGemVarieties() async {
    return GemType.values.map((t) => t.displayName).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INVENTORY CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Insert a gemstone. Returns the assigned integer key.
  Future<int> insertGemstone(GemstoneModel gem) async {
    final box = await _box;
    // toMap() returns the full flat representation GemstoneModel already defines
    final map = gem.toMap()..remove('id'); // let Hive assign the key
    return await box.add(Map.from(map));
  }

  /// Fetch all gemstones, newest first (by Hive key descending).
  Future<List<GemstoneModel>> getAllGemstones() async {
    final box = await _box;
    final entries = box.toMap().entries.toList()
      ..sort((a, b) => (b.key as int).compareTo(a.key as int));
    return entries
        .map((e) => GemstoneModel.fromMap(_injectId(e.key as int, e.value)))
        .toList();
  }

  /// Fetch only unsold gemstones, newest first.
  Future<List<GemstoneModel>> getUnsoldGemstones() async {
    final all = await getAllGemstones();
    return all.where((g) => !g.isSold).toList();
  }

  /// Update an existing gemstone (identified by [gem.id]).
  Future<void> updateGemstone(GemstoneModel gem) async {
    if (gem.id == null) throw ArgumentError('Cannot update a gem without an id');
    final box = await _box;
    if (!box.containsKey(gem.id)) {
      throw Exception('Update failed: record not found for id ${gem.id}');
    }
    final map = gem.toMap()..remove('id');
    await box.put(gem.id, Map.from(map));
  }

  /// Delete a gemstone by key.
  Future<void> deleteGemstone(int id) async {
    final box = await _box;
    await box.delete(id);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANALYTICS  (all pure-Dart replacements of the raw SQL queries)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Business summary — equivalent of the GROUP aggregate SQL in AnalyticsRepository.
  Future<BusinessSummary> getBusinessSummary({String? gemVariety}) async {
    final allGems = await getAllGemstones();
    final sold = allGems.where((g) {
      if (!g.isSold) return false;
      if (gemVariety != null && gemVariety.isNotEmpty) {
        return g.variety == gemVariety;
      }
      return true;
    }).toList();

    if (sold.isEmpty) {
      return BusinessSummary(
        totalProfit: 0,
        totalExpenses: 0,
        totalRevenue: 0,
        totalInventorySold: 0,
        averageProfit: 0,
        averageSellingTime: 0,
      );
    }

    double totalRevenue = 0;
    double totalExpenses = 0;
    double totalSellingDays = 0;
    int sellingDaysCount = 0;

    for (final g in sold) {
      final rev = _calcRevenue(g);
      final exp = _calcExpenses(g);
      totalRevenue += rev;
      totalExpenses += exp;

      final bought = _julianDay(g.buyingDate);
      final sold_ = _julianDay(g.recordDate);
      if (bought != null && sold_ != null) {
        totalSellingDays += (sold_ - bought);
        sellingDaysCount++;
      }
    }

    final totalProfit = totalRevenue - totalExpenses;
    return BusinessSummary(
      totalProfit: totalProfit,
      totalExpenses: totalExpenses,
      totalRevenue: totalRevenue,
      totalInventorySold: sold.length,
      averageProfit: totalProfit / sold.length,
      averageSellingTime:
          sellingDaysCount > 0 ? totalSellingDays / sellingDaysCount : 0,
    );
  }

  /// Monthly performance breakdown, sorted ascending by month.
  Future<List<MonthlyPerformance>> getMonthlyPerformance() async {
    final allGems = await getAllGemstones();
    final sold = allGems.where((g) => g.isSold && g.buyingDate.isNotEmpty);

    // Group by 'yyyy-MM'
    final Map<String, _MonthAccum> buckets = {};
    for (final g in sold) {
      final month = g.buyingDate.length >= 7 ? g.buyingDate.substring(0, 7) : null;
      if (month == null) continue;
      final rev = _calcRevenue(g);
      final exp = _calcExpenses(g);
      buckets.putIfAbsent(month, () => _MonthAccum());
      buckets[month]!.revenue += rev;
      buckets[month]!.expenses += exp;
    }

    final result = buckets.entries
        .map((e) => MonthlyPerformance(
              month: e.key,
              revenue: e.value.revenue,
              expenses: e.value.expenses,
              profit: e.value.revenue - e.value.expenses,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return result;
  }

  /// Top performing gem types, sorted by average profit descending.
  Future<List<GemTypePerformance>> getTopPerformingGems() async {
    final allGems = await getAllGemstones();
    final sold = allGems.where((g) => g.isSold);

    final Map<String, _GemAccum> buckets = {};
    for (final g in sold) {
      final variety = g.variety.isEmpty ? 'Unknown' : g.variety;
      final rev = _calcRevenue(g);
      final exp = _calcExpenses(g);
      buckets.putIfAbsent(variety, () => _GemAccum());
      buckets[variety]!.totalRevenue += rev;
      buckets[variety]!.totalProfit += (rev - exp);
      buckets[variety]!.count++;

      final bought = _julianDay(g.buyingDate);
      final soldDate = _julianDay(g.recordDate);
      if (bought != null && soldDate != null) {
        buckets[variety]!.totalDays += (soldDate - bought);
        buckets[variety]!.daysCount++;
      }
    }

    final result = buckets.entries
        .map((e) {
          final avgProfit = e.value.count > 0 ? e.value.totalProfit / e.value.count : 0.0;
          final avgDays = e.value.daysCount > 0
              ? e.value.totalDays / e.value.daysCount
              : 0.0;
          return GemTypePerformance(
            gemType: e.key,
            averageProfit: avgProfit,
            totalSales: e.value.count.toDouble(),
            totalRevenue: e.value.totalRevenue,
            averageSellingTime: avgDays,
          );
        })
        .toList()
      ..sort((a, b) => b.averageProfit.compareTo(a.averageProfit));

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PREDICTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Compute a price/profit prediction for a given gem type + optional filters.
  /// Pure-Dart replacement for the nested rawQuery in PredictionRepository.
  Future<PredictionModel> getPrediction({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  }) async {
    final normalizedGemType = gemType.trim();
    if (normalizedGemType.isEmpty) {
      return PredictionModel.empty(gemType: gemType);
    }

    final allGems = await getAllGemstones();

    // Apply the same filters the SQL WHERE clause expressed
    final matched = allGems.where((g) {
      if (!g.isSold) return false;

      // variety OR category match
      final varietyMatch =
          g.variety == normalizedGemType || g.category == normalizedGemType;
      if (!varietyMatch) return false;

      if ((category ?? '').trim().isNotEmpty && category != 'All') {
        if (g.category != category) return false;
      }

      if ((origin ?? '').trim().isNotEmpty && origin != 'All') {
        if (g.origin != origin) return false;
      }

      if (purchasePrice != null && purchasePrice > 0) {
        final lower = purchasePrice * 0.8;
        final upper = purchasePrice * 1.2;
        if (g.buyingPrice < lower || g.buyingPrice > upper) return false;
      }

      if (weight != null && weight > 0) {
        final lower = weight * 0.8;
        final upper = weight * 1.2;
        if (g.buyingWeight < lower || g.buyingWeight > upper) return false;
      }

      if ((color ?? '').trim().isNotEmpty) {
        if (g.buyingColor != color && g.finalColor != color) return false;
      }

      if ((clarity ?? '').trim().isNotEmpty) {
        if (g.clarity != clarity) return false;
      }

      return true;
    }).toList();

    if (matched.isEmpty) {
      return PredictionModel.empty(gemType: normalizedGemType);
    }

    // Aggregates
    double totalProfit = 0;
    double totalExpenses = 0;
    double totalSellingPrice = 0;
    double totalDays = 0;
    int daysCount = 0;

    // For bestSellingMonth: group profit by 'yyyy-MM'
    final Map<String, double> monthProfits = {};
    // For mostProfitableGemType: group profit by variety
    final Map<String, double> varietyProfits = {};

    for (final g in matched) {
      final rev = _calcRevenue(g);
      final exp = _calcExpenses(g);
      final profit = rev - exp;
      totalProfit += profit;
      totalExpenses += exp;
      totalSellingPrice += rev;

      final bought = _julianDay(g.buyingDate);
      final soldDate = _julianDay(g.recordDate);
      if (bought != null && soldDate != null) {
        totalDays += (soldDate - bought);
        daysCount++;
      }

      final month = g.recordDate.length >= 7 ? g.recordDate.substring(0, 7) : null;
      if (month != null) {
        monthProfits[month] = (monthProfits[month] ?? 0) + profit;
      }

      final v = g.variety.isEmpty ? 'Unknown' : g.variety;
      varietyProfits[v] = (varietyProfits[v] ?? 0) + profit;
    }

    final count = matched.length;
    final avgProfit = totalProfit / count;
    final avgExpenses = totalExpenses / count;
    final avgSellingPrice = totalSellingPrice / count;
    final avgDays = daysCount > 0 ? totalDays / daysCount : 0.0;
    final profitMargin =
        avgSellingPrice > 0 ? ((avgSellingPrice - avgExpenses) / avgSellingPrice) * 100 : 0.0;

    final bestMonth = monthProfits.isEmpty
        ? 'N/A'
        : (monthProfits.entries.reduce((a, b) => a.value >= b.value ? a : b).key);

    final bestVariety = varietyProfits.isEmpty
        ? normalizedGemType
        : (varietyProfits.entries.reduce((a, b) => a.value >= b.value ? a : b).key);

    final confidence = count <= 5 ? 'Low' : count <= 20 ? 'Medium' : 'High';

    return PredictionModel(
      gemType: normalizedGemType,
      matchingRecordCount: count,
      averageProfit: avgProfit,
      averageExpenses: avgExpenses,
      averageSellingPrice: avgSellingPrice,
      averageDaysToSell: avgDays,
      profitMarginPercent: profitMargin,
      totalInventoryProfit: totalProfit,
      monthlyProfit: 0.0,
      monthlyExpense: 0.0,
      bestSellingMonth: bestMonth,
      mostProfitableGemType: bestVariety,
      expectedExpenses: avgExpenses,
      expectedSellingPrice: avgSellingPrice,
      expectedProfit: avgProfit,
      expectedDaysToSell: avgDays,
      confidenceLevel: confidence,
    );
  }

  // ─── Private helpers ──────────────────────────────────────────────────────
  Map<String, dynamic> _injectId(int key, Map rawMap) {
    final map = Map<String, dynamic>.from(rawMap);
    map['id'] = key;
    return map;
  }
}

// ─── Private accumulator helpers (not part of public API) ────────────────────
class _MonthAccum {
  double revenue = 0;
  double expenses = 0;
}

class _GemAccum {
  double totalRevenue = 0;
  double totalProfit = 0;
  int count = 0;
  double totalDays = 0;
  int daysCount = 0;
}