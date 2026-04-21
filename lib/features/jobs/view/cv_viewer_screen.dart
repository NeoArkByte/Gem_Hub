import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CvViewerScreen extends StatelessWidget {
  final String cvPath;
  final String applicantName;

  const CvViewerScreen({
    Key? key, 
    required this.cvPath, 
    required this.applicantName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 👇 Supabase dammata passe URL eka enawada, nattam local file ekakda kiyala check karanawa
    bool isNetworkPdf = cvPath.startsWith('http://') || cvPath.startsWith('https://');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "$applicantName's CV", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
      ),
      body: cvPath.isEmpty 
          ? const Center(child: Text("CV file path is missing 📄"))
          : isNetworkPdf
              // URL ekak nam (Supabase walin passe) meken open karanawa
              ? SfPdfViewer.network(cvPath) 
              // Local phone eke file ekak nam meken open karanawa
              : SfPdfViewer.file(File(cvPath)), 
    );
  }
}