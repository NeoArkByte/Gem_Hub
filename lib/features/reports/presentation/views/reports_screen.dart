import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/data/models/inventory/gem_filter.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/reports/presentation/view_models/report_view_model.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  GemFilter _currentFilter = GemFilter();

  @override
  Widget build(BuildContext context) {
    final gemsAsync = ref.watch(
      filteredGemstonesProvider(filter: _currentFilter),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Inventory Report"), elevation: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
        onPressed: () => _exportReport(gemsAsync.value ?? []),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: gemsAsync.when(
              data: (gems) {
              
                final totalPortfolio = gems.fold<double>(
                  0,
                  (sum, gem) => sum + (gem.isSold ? 0.0 : gem.targetPrice),
                );

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTotalHeader(totalPortfolio),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gems.length,
                        itemBuilder: (context, index) =>
                            _buildGemCard(gems[index]),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHeader(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Portfolio Value",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "LKR ${total.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
   
    final varietiesAsync = ref.watch(gemstoneVarietiesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Date Filter
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(
                    () => _currentFilter = _currentFilter.copyWith(
                      dateRange: picked,
                    ),
                  );
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "Month",
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 20,
                      color: _currentFilter.dateRange != null
                          ? AppColors.primaryYellow
                          : Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Real Varieties Dropdown
          Expanded(
            flex: 3,
            child: varietiesAsync.when(
              data: (varieties) => DropdownButtonFormField<String>(
                initialValue: _currentFilter.variety ?? 'All',
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "Variety",
                ),
                items: varieties
                    .map(
                      (val) => DropdownMenuItem(
                        value: val,
                        child: Text(val, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(
                    () => _currentFilter = _currentFilter.copyWith(
                      variety: value,
                    ),
                  );
                },
              ),
              
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => const Text("Error"),
            ),
          ),
          const SizedBox(width: 8),

          // Status Dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: _currentFilter.status ?? 'All',
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: "Status",
              ),
              items: ['All', 'Available', 'Sold']
                  .map(
                    (val) => DropdownMenuItem(
                      value: val,
                      child: Text(val, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(
                  () => _currentFilter = _currentFilter.copyWith(status: value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(List<GemstoneModel> gems) async {
    
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
      }
    }

    // Ask user to select export location and filename
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Report As',
      fileName: 'Gem_Hub_Inventory_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputFile == null) {
      
      return;
    }

    // create PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gem Hub Inventory Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                ]
              )
            ),
            pw.SizedBox(height: 10),
            pw.Text('User: Gem Hub Admin', style: const pw.TextStyle(fontSize: 14)), 
            pw.Text('Status Filter: ${_currentFilter.status ?? 'All'}', style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Variety Filter: ${_currentFilter.variety ?? 'All'}', style: const pw.TextStyle(fontSize: 14)),
            if (_currentFilter.dateRange != null)
              pw.Text('Date Range: ${DateFormat('yyyy-MM-dd').format(_currentFilter.dateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_currentFilter.dateRange!.end)}', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Gem Name', 'Date', 'Status', 'Cost', 'Target/Sold Price', 'Profit'],
              data: gems.map((gem) {
                final double totalCost = gem.buyingPrice + gem.treatmentCost + gem.recutCost + gem.otherProcessingCost + gem.transportCost + gem.otherCost;
                final double displayProfit = gem.isSold ? (gem.sellingPrice - totalCost) : (gem.targetPrice - totalCost);
                
                return [
                  '${gem.variety} (${gem.color})',
                  gem.date,
                  gem.isSold ? 'Sold' : 'Available',
                  'Rs. ${NumberFormat('#,###').format(totalCost)}',
                  'Rs. ${NumberFormat('#,###').format(gem.isSold ? gem.sellingPrice : gem.targetPrice)}',
                  'Rs. ${NumberFormat('#,###').format(displayProfit)}',
                ];
              }).toList(),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text('© ${DateTime.now().year} Gem Hub Application. All rights reserved.', style: const pw.TextStyle(color: PdfColors.grey)),
          );
        },
      ),
    );

    // Save the PDF file 
    try {
      final file = File(outputFile);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report successfully saved to $outputFile'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

Widget _buildGemCard(GemstoneModel gem) {
  // Calculate Total Cost
  final double totalCost =
      gem.buyingPrice +
      gem.treatmentCost +
      gem.recutCost +
      gem.otherProcessingCost +
      gem.transportCost +
      gem.otherCost;


  final double displayProfit = gem.isSold
      ? (gem.sellingPrice - totalCost)
      : (gem.targetPrice - totalCost);

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Image Section with "SOLD" badge overlay
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      gem.finalImagePath != null &&
                          gem.finalImagePath!.isNotEmpty
                      ? Image.file(
                          File(gem.finalImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.diamond, color: Colors.blueGrey),
                ),
              ),
              if (gem.isSold)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SOLD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),

          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gem.variety,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gem.date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

          // Profit Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gem.isSold ? "Profit" : "Target Profit",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                "LKR ${NumberFormat('#,###').format(displayProfit)}",
                style: TextStyle(
                  color: displayProfit >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
