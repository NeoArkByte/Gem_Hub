import 'package:flutter/material.dart';
import 'package:test_ravidu/widgets/job_card.dart';
import '../../db/db_helper.dart';
import 'job_request.dart';
import '../UserScreens/Jobs_Ads.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF003366),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_late_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobPostRequestsScreen(),
                ),
              ).then((value) => setState(() {}));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddJobScreen()),
              ).then((value) => setState(() {}));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getJobsByStatus(
          'approved',
        ), 
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data!;
          if (jobs.isEmpty)
            return const Center(child: Text("No Approved Jobs to Show"));

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(
              job: jobs[index],
              onDelete: () async {
                await DBHelper.deleteJob(jobs[index]['id']);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}
