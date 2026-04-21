import 'package:flutter/material.dart';
import 'package:job_market/features/auth/view/login_screen.dart'; // Check your path
import 'package:job_market/data/datasources/local/database_helper.dart'; 
import 'package:job_market/features/marketplace/view/notification_screen.dart'; // 👈 Path eka hariyata danna

class AdminJobReviewScreen extends StatefulWidget {
  const AdminJobReviewScreen({Key? key}) : super(key: key);

  @override
  State<AdminJobReviewScreen> createState() => _AdminJobReviewScreenState();
}

class _AdminJobReviewScreenState extends State<AdminJobReviewScreen> {
  final Color primaryGreen = const Color(0xFF10C971);
  final Color primaryYellow = const Color(0xFFFDB913); 
  final Color bgColor = const Color(0xFFF8F9FA);
  final Color textColor = const Color(0xFF111827);
  final Color greyText = const Color(0xFF6B7280);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to log out of the admin panel?', style: TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text('Cancel', style: TextStyle(color: greyText, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), 
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAdminHeader(context),
            _buildSearchBar(),
            _buildCategories(),
            _buildSectionHeader('Pending Job Post Listings', Icons.hourglass_empty),
            
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getPendingJobs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFDB913)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('All caught up! No pending jobs.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  final pendingJobs = snapshot.data!;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: pendingJobs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final job = pendingJobs[index];
                      return JobPostReviewCard(
                        title: job['title'],
                        companyInfo: job['companyInfo'],
                        salary: job['salary'],
                        tags: (job['tags'] as String).split(','),
                        logoColor: Color(job['logoColor']),
                        
                        onAccept: () async {
                          await DatabaseHelper().updateJobStatus(job['id'], 'approved');
                          await DatabaseHelper().addNotification(
                            job['employer_id'], 
                            "Job Approved! ✅", 
                            "Your job '${job['title']}' has been approved and is now live."
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accepted: ${job['title']}'), backgroundColor: primaryGreen));
                            setState(() {}); 
                          }
                        },
                        
                        onReject: () async {
                          await DatabaseHelper().updateJobStatus(job['id'], 'rejected');
                          await DatabaseHelper().addNotification(
                            job['employer_id'], 
                            "Job Update ⚠️", 
                            "Your job '${job['title']}' was not approved by the admin."
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejected: ${job['title']}'), backgroundColor: const Color(0xFFEF4444)));
                            setState(() {}); 
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: primaryYellow, shape: BoxShape.circle),
            child: const CircleAvatar(radius: 22, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33')),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin - Job Post Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Text('Review new pending listings', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
            child: IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.grey[800], size: 22),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              },
              splashRadius: 24,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
            child: IconButton(
              icon: Icon(Icons.logout, color: const Color(0xFFEF4444).withOpacity(0.9), size: 22),
              onPressed: () => _showLogoutDialog(context),
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]),
              child: TextField(
                decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.grey[400]), hintText: 'Search pending job titles...', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)), child: Icon(Icons.tune, color: Colors.grey[600], size: 20)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    // 👇 ALUTH CATEGORIES TIKA ADMIN EKATATH DAMMA
    final categories = ['All Pending', 'Gem Cutter', 'Polisher', 'Gemologist', 'Jewelry Designer', 'Bench Jeweler', 'Sales Executive'];
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: categories.map((cat) {
            bool isSelected = cat == 'All Pending';
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(color: isSelected ? const Color(0xFF131B2A) : Colors.white, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3))),
                child: Text(cat, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: primaryYellow, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// (JobPostReviewCard eka wenas une na)
class JobPostReviewCard extends StatelessWidget {
  final String title;
  final String companyInfo;
  final String salary;
  final List<String> tags;
  final Color logoColor;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const JobPostReviewCard({Key? key, required this.title, required this.companyInfo, required this.salary, required this.tags, required this.logoColor, required this.onAccept, required this.onReject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Center(child: Container(width: 36, height: 36, color: logoColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
                        Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10C971))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(companyInfo, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: tags.map((tag) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])))).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1)),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: onReject, icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20), label: const Text("Reject", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: onAccept, icon: const Icon(Icons.check, color: Colors.white, size: 20), label: const Text("Accept", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10C971), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)))),
            ],
          ),
        ],
      ),
    );
  }
}