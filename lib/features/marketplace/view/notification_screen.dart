import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('logged_in_user_id') ?? '';
    return await DatabaseHelper().getNotifications(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    // ... UI colors (kalin thibba wagema) ...

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("No notifications yet."));

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['message']),
                trailing: Text(
                  item['time'].toString().substring(11, 16),
                ), // Time ekak pamanak
              );
            },
          );
        },
      ),
    );
  }
}
