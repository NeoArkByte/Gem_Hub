// lib/data/models/job_market/job_model.dart

class Job {
  final String? jobId;
  final String employerId;
  final String title;
  final String? companyInfo; // Django වල null=True නිසා String? කළා
  final double? salary;      // Django වල FloatField නිසා double? කළා
  final String tags;
  final String status;
  final String? createdAt;

  Job({
    this.jobId,
    required this.employerId,
    required this.title,
    this.companyInfo,
    this.salary,
    required this.tags,
    required this.status,
    this.createdAt,
  });

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    final stringValue = value.toString().replaceAll(',', '').trim();
    return double.tryParse(stringValue);
  }

  // DB එකෙන් එන data (Map) එක Job Object එකට හරවනවා
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      // Backend එකේ හරියටම එන Keys පාවිච්චි කරලා තියෙනවා (snake_case)
      jobId: map['job_id']?.toString() ?? map['id']?.toString() ?? map['pk']?.toString(),
      employerId: map['employer']?.toString() ?? map['employer_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'No Title',
      companyInfo: map['company_info']?.toString() ?? map['company']?.toString(),
      
      // FloatField එක ආරක්ෂිතව double එකකට හරවා ගැනීම
      salary: _parseNullableDouble(map['salary']),
      
      tags: map['tags']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString(),
    );
  }

  // Job Object එක ආයෙත් DB එකට දාන්න පුළුවන් විදිහට Map කරනවා
  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'employer': employerId,
      'title': title,
      'company_info': companyInfo,
      'salary': salary,
      'tags': tags,
      'status': status,
      'created_at': createdAt,
    };
  }
}