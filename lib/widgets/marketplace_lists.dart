import 'package:flutter/material.dart';
import 'package:job_market/db/database_helper.dart'; 
import 'package:job_market/widgets/featured_job_card.dart'; 
import 'package:job_market/widgets/recent_job_card.dart'; 
// 👇 OYAGE DETAILS SCREEN EKA IMPORT KARANNA (Path eka hariyata danna)
import 'package:job_market/Screen/job_details.dart'; 

class FeaturedJobsList extends StatelessWidget {
  const FeaturedJobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getFeaturedJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF10C971)));
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(children: [
                Icon(Icons.diamond_outlined, color: Colors.grey[400], size: 32),
                Text('No new jobs listed today.', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                Text('Post a job to see it listed here!', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ]),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: snapshot.data!.map((job) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              // 👇 MEKA THAMAI CLICK KARANNA DENA KALLA 👇
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
                  );
                },
                child: FeaturedJobCard(
                  title: job['title'], 
                  company: job['companyInfo'], 
                  salary: job['salary'], 
                  timePosted: 'New', 
                  isPremium: true, 
                  logoColor: Color(job['logoColor'])
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }
}

class RecentJobsList extends StatelessWidget {
  const RecentJobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getApprovedJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF10C971)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No recent jobs found.'));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: snapshot.data!.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              // 👇 MEKA THAMAI CLICK KARANNA DENA KALLA 👇
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
                  );
                },
                child: RecentJobCard(
                  title: job['title'], 
                  companyInfo: job['companyInfo'], 
                  salary: job['salary'], 
                  tags: (job['tags'] as String).split(','), 
                  logoColor: Color(job['logoColor'])
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }
}