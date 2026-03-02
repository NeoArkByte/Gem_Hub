import 'package:flutter/material.dart';
import '../../db/db_helper.dart';

class JobPostRequestsScreen extends StatefulWidget {
  @override
  _JobPostRequestsScreenState createState() => _JobPostRequestsScreenState();
}

class _JobPostRequestsScreenState extends State<JobPostRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Requests"), backgroundColor: Colors.orange[800]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getJobsByStatus('request'), // 'request' ඒවා විතරයි මෙතන පෙන්වන්නේ
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!;
          if (requests.isEmpty) return const Center(child: Text("No Pending Requests"));

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) => Card(
              color: Colors.orange[50],
              child: ListTile(
                title: Text(requests[index]['title']),
                subtitle: Text(requests[index]['location']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await DBHelper.updateJobStatus(requests[index]['id'], 'approved');
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        await DBHelper.deleteJob(requests[index]['id']);
                        setState(() {});
                      },
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
}