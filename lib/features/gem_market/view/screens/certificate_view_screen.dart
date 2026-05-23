import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:gemhub/features/gem_market/viewmodel/certificate/certificate_viewmodel.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class CertificateViewScreen extends ConsumerWidget {
  final String url;
  final String gemName;

  const CertificateViewScreen({
    super.key,
    required this.url,
    required this.gemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.darkBackground : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    final certificateAsync = ref.watch(certificateViewModelProvider(url));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '$gemName Certificate',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: certificateAsync.maybeWhen(
              data: (signedUrl) => () {},
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: certificateAsync.when(
        data: (signedUrl) => SfPdfViewer.network(
          signedUrl,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load PDF: ${details.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load certificate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref
                      .read(certificateViewModelProvider(url).notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
