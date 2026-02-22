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
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    //DBHelper.approveJob(jobs[index]['id']);
                    //setState(() {});
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
