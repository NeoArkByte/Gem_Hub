import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // ඇඩ්මින්ට විතරක් පාවිච්චි කරන්න

  const JobCard({super.key, required this.job, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50], 
            borderRadius: BorderRadius.circular(8)
          ),
          child: const Icon(Icons.business_center, color: Color(0xFF003366)),
        ),
        title: Text(
          job['title'], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job['location']),
            const SizedBox(height: 5),
            Text(
              "Rs. ${job['salary']}", 
              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)
            ),
          ],
        ),
        // onDelete එකක් එව්වොත් විතරක් delete බටන් එක පෙන්වනවා
        trailing: onDelete != null 
          ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}