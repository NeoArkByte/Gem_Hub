import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CertificateViewScreen extends StatelessWidget {
  final String url;
  final String gemName;

  const CertificateViewScreen({
    super.key,
    required this.url,
    required this.gemName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$gemName Certificate'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // Future: Implement download
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        url,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load certificate: ${details.error}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
