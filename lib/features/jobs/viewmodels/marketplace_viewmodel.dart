import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_viewmodel.g.dart';

@riverpod
class MarketplaceViewModel extends _$MarketplaceViewModel {
  // 1. මේකෙ තමයි මුල් ජොබ්ස් සේරම තියාගන්නේ (Master List එක)
  List<Job> _allJobs = [];

  // 2. දැනට තෝරලා තියෙන ෆිල්ටර්ස් (Default අගයන්)
  String _query = '';
  String _category = 'All Jobs';
  String _location = 'All Locations';
  double _minSalary = 0;
  double _maxSalary = 300000;

  String get currentCategory => _category;
  String get currentLocation => _location;
  double get currentMinSalary => _minSalary;
  double get currentMaxSalary => _maxSalary;

  @override
  Future<List<Job>> build() async {
    // මුලින්ම ඇප් එක ලෝඩ් වෙද්දී සේරම ජොබ් ටික Backend එකෙන් ගන්නවා
    final repository = ref.read(jobRepositoryProvider);
    _allJobs = await repository
        .getApprovedJobs(); // කිසිම ෆිල්ටර් එකක් යවන්නේ නෑ
    return _allJobs;
  }

  // =========================================================
  // 💡 මැජික් එක තියෙන්නේ මෙතන! මේකෙන් තමයි දත්ත පෙරන්නේ
  // =========================================================
  void _applyFilters() {
    print("🔍 [FILTER START] ------------------------");
    print(
      "🎯 යූසර් තෝරපු Filters: Category='$_category', Location='$_location', Salary='$_minSalary - $_maxSalary'",
    );
    print("📦 මුළු ජොබ්ස් ගාණ: ${_allJobs.length}");

    final filteredList = _allJobs.where((job) {
      // 1. Search Check
      bool matchesQuery = true;
      if (_query.isNotEmpty) {
        matchesQuery = job.title.toLowerCase().contains(_query.toLowerCase());
      }

      // 2. Category Check
      bool matchesCategory = true;
      if (_category.isNotEmpty && _category != 'All Jobs') {
        matchesCategory = job.tags.toLowerCase().contains(
          _category.toLowerCase(),
        );
        print(
          "   🏷️ ජොබ් එක: '${job.title}' | Model එකේ Tags: '${job.tags}' | Category Match ද? $matchesCategory",
        );
      }

      // 3. Location Check
      bool matchesLocation = true;
      if (_location.isNotEmpty && _location != 'All Locations') {
        final jobLocation = job.companyInfo?.toLowerCase() ?? '';
        matchesLocation = jobLocation.contains(_location.toLowerCase());
        print(
          "   📍 ජොබ් එක: '${job.title}' | Model එකේ Location: '$jobLocation' | Location Match ද? $matchesLocation",
        );
      }

      // 4. Salary Check (💡 අලුත් Min/Max රේන්ජ් ලොජික් එක)
      bool matchesSalary = true;
      if (job.minSalary != null || job.maxSalary != null) {
        
        // ජොබ් එකේ දීලා තියෙන අවම සහ උපරිම පඩි ගන්නවා. එකක් නැත්නම් 0 හෝ අසීමිත (infinity) අගයක් දෙනවා.
        double jobMin = job.minSalary ?? 0;
        double jobMax = job.maxSalary ?? double.infinity;

        // ෆිල්ටර් රේන්ජ් එකයි ජොබ් එකේ රේන්ජ් එකයි ගැළපෙනවද (overlap වෙනවද) බලනවා
        matchesSalary = (jobMin <= _maxSalary) && (jobMax >= _minSalary);
      }

      bool isPassed =
          matchesQuery && matchesCategory && matchesLocation && matchesSalary;
      if (!isPassed) {
        print(
          "   ❌ '${job.title}' කැපිලා ගියා! (Query:$matchesQuery, Cat:$matchesCategory, Loc:$matchesLocation, Sal:$matchesSalary)",
        );
      } else {
        print("   ✅ '${job.title}' තේරුණා!");
      }

      return isPassed;
    }).toList();

    print("🎉 Filter වුණාට පස්සේ ඉතුරු ජොබ්ස් ගාණ: ${filteredList.length}");
    print("------------------------------------------");

    state = AsyncValue.data(filteredList);
  }

  // =========================================================
  // යූසර් කරන දේවල් අල්ලගන්න Functions
  // =========================================================

  // Search Bar එකේ අකුරු ගහද්දී
  void updateSearchQuery(String query) {
    _query = query;
    _applyFilters();
  }

  void clearFilters() {
    _category = 'All Jobs';
    _location = 'All Locations';
    _minSalary = 0;
    _maxSalary = 300000;

    _applyFilters();
  }

  // උඩ තියෙන Category ටැබ් ඔබද්දී
  void updateCategory(String category) {
    _category = category;
    _applyFilters();
  }

  // අලුත් Bottom Sheet එකෙන් Apply කරද්දී
  void updateFilters({
    required String category,
    required String location,
    required double minSalary,
    required double maxSalary,
  }) {
    // අලුත් අගයන් ටික සෙට් කරනවා
    _category = category;
    _location = location;
    _minSalary = minSalary;
    _maxSalary = maxSalary;

    // ෆිල්ටර් එක රන් කරනවා
    _applyFilters();
  }
}