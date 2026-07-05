import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/shared/widgets/custom_toast.dart';

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
            onPressed: url.isEmpty 
                ? null 
                : () {
                  
                  },
          ),
        ],
      ),
      body: url.isEmpty
          ? const Center(
              child: Text(
                'No certificate provided.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SfPdfViewer.network(
              url,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomToast.showError(
                    context, 
                    'Failed to load PDF: ${details.error}',
                  );
                });
              },
            ),
    );
  }
}