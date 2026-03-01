import 'package:flutter/material.dart';
import 'package:test_ravidu/db/db_helper.dart';

class AdminScreen extends StatefulWidget {
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getJobs("pending"),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final jobs = snapshot.data!;
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) => Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(jobs[index]['title']),
                subtitle: Text(jobs[index]['location']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept Button
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await DBHelper.approveJob(jobs[index]['id']);
                        setState(() {});
                      },
                    ),
                    // Decline Button
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _showRejectDialog(jobs[index]['id']),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRejectDialog(int jobId) {
    final _reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reject Job"),
        content: TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            hintText: "Reason (e.g. Invalid Contact)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_reasonController.text.isNotEmpty) {
                await DBHelper.rejectJob(jobId, _reasonController.text);
                Navigator.pop(context);
                setState(() {}); // Admin list eka refresh karanawa
              }
            },
            child: Text("Reject"),
          ),
        ],
      ),
    );
  }
}
