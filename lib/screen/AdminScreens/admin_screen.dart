import 'package:flutter/material.dart';
import 'package:test_ravidu/screen/login.dart';
import 'package:test_ravidu/widgets/job_card.dart';
import '../../db/db_helper.dart';
import 'job_request.dart';
import '../UserScreens/Jobs_Ads.dart';
// import '../screens/login_screen.dart'; // ඔයාගේ ලොගින් පේජ් එක මෙතනට දාන්න

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // මෙන්න අර User Screen එකේ වගේ ලස්සන කරපු AppBar එක
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110), // සර්ච් බාර් නැති නිසා උස 110ක් ඇති
        child: Container(
          color: const Color(0xFF003366),
          padding: const EdgeInsets.only(left: 15, right: 5, top: 45, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. වම් පැත්තේ තියෙන Title එක (Gem Hub Admin)
              const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text("Gem Hub ", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Admin", style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              
              // 2. දකුණු පැත්තේ තියෙන Icon Buttons ටික
              Row(
                children: [
                  // Pending Requests Icon
                  IconButton(
                    icon: const Icon(Icons.assignment_late_outlined, color: Colors.white),
                    tooltip: "Job Requests",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JobPostRequestsScreen()),
                      ).then((value) => setState(() {}));
                    },
                  ),
                  // Add Job Icon
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                    tooltip: "Add New Job",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddJobScreen()),
                      ).then((value) => setState(() {}));
                    },
                  ),
                  // Logout Icon
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: "Logout",
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                      print("Admin Logged Out!");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // අලුත් AppBar එකට යටින් පොඩි මාතෘකාවක් දාමු
          const Padding(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 5),
            child: Text(
              "Approved Jobs", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
          ),
          const Divider(thickness: 1),
          
          // ජොබ් ලිස්ට් එක පෙන්වන කොටස
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.getJobsByStatus('approved'), 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final jobs = snapshot.data!;
                if (jobs.isEmpty) {
                  return const Center(
                    child: Text("No Approved Jobs to Show", style: TextStyle(fontSize: 16, color: Colors.grey))
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 5, bottom: 20),
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
          ),
        ],
      ),
    );
  }
}