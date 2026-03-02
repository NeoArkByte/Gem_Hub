import 'package:flutter/material.dart';
import 'package:test_ravidu/db/db_helper.dart';
import 'package:test_ravidu/widgets/job_card.dart';

class Userhomescreen extends StatefulWidget {
  const Userhomescreen({super.key});

  @override
  State<Userhomescreen> createState() => _UserhomescreenState();
}

class _UserhomescreenState extends State<Userhomescreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _LocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        
        preferredSize: const Size.fromHeight(220), 
        child: Container(
          color: const Color(0xFF003366),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column( 
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tag_faces, color: Colors.white),
                  SizedBox(width: 5),
                  Text("Gem Hub ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Jobs ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              _buildSearchField(Icons.search, "Search for jobs, companies...", _searchController),
              const SizedBox(height: 10),
              _buildSearchField(Icons.location_on, "Search by location...", _LocationController, hasSuffix: true),
            ],
          ),
        ),
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

  Widget _buildSearchField(IconData icon, String hint, TextEditingController controller, {bool hasSuffix = false}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: hasSuffix ? const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}