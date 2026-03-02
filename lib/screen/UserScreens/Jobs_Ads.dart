import 'package:flutter/material.dart';
import '../../db/db_helper.dart';

class AddJobScreen extends StatefulWidget {
  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _title = TextEditingController(), _loc = TextEditingController(), _sal = TextEditingController(), _desc = TextEditingController();

  void _submit() async {
    if (_title.text.isEmpty || _loc.text.isEmpty) return;
    
    await DBHelper.insertJob({
      'title': _title.text,
      'location': _loc.text,
      'salary': _sal.text,
      'description': _desc.text,
      'status': 'request', // මෙතන 'request' දාන නිසා තමයි ඒක Pending ලිස්ට් එකට යන්නේ
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post New Job"), backgroundColor: const Color(0xFF003366)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Job Title")),
            TextField(controller: _loc, decoration: const InputDecoration(labelText: "Location")),
            TextField(controller: _sal, decoration: const InputDecoration(labelText: "Salary")),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text("Submit Job Request")),
          ],
        ),
      ),
    );
  }
}