import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👇 Added for User ID
import 'package:job_market/db/database_helper.dart'; 

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  final Color primaryGreen = const Color(0xFF10C971);

  void _openCV(String? path) async {
    if (path != null && path.isNotEmpty) {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open CV: ${result.message}'), backgroundColor: Colors.red));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV file path is missing!'), backgroundColor: Colors.red));
    }
  }

  // 👇 ALUTH FUNCTION EKA: User ge ID eka aran eyage applications witharak gannawa
  Future<List<Map<String, dynamic>>> _fetchMyApplications() async {
    final prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('logged_in_user_id') ?? '';
    
    if (currentUserId.isEmpty) return [];
    
    return await DatabaseHelper().getReceivedApplications(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text('Received Applications', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // 👇 Methanata aluth function eka damma
        future: _fetchMyApplications(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No applications received yet.', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            );
          }

          final applications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: applications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final app = applications[index];
              return _buildApplicationCard(app, isDark, textColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app, bool isDark, Color textColor) {
    Color cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[200]!;
    Color greyText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('Applied for: ${app['job_title'] ?? 'Unknown Job'}', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: isDark ? const Color(0xFF374151) : Colors.grey[100], child: Icon(Icons.person, color: isDark ? Colors.grey[300] : Colors.grey[400])),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app['applicant_name'] ?? 'No Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    Row(children: [Icon(Icons.phone, size: 14, color: greyText), const SizedBox(width: 4), Text(app['phone'] ?? 'No Phone', style: TextStyle(fontSize: 14, color: greyText))]),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expected Salary:', style: TextStyle(color: greyText, fontSize: 14)),
              Text(app['expected_salary'] != null && app['expected_salary'].toString().isNotEmpty ? 'Rs. ${app['expected_salary']}' : 'Negotiable', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openCV(app['cv_path']),
              icon: Icon(Icons.description_outlined, color: primaryGreen),
              label: Text('View Uploaded CV', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 15)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: primaryGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }
}