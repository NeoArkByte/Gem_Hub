// lib/data/models/job_market/job_model.dart

class Job {
  final String? jobId;
  final String employerId;
  final String title;
  final String? companyInfo; 
  ///final double? salary;      
  final String tags;
  final String status;
  final String? createdAt;
  final String? description;

  final double? minSalary;
  final double? maxSalary;

  Job({
    this.jobId,
    required this.employerId,
    required this.title,
    this.companyInfo,
    this.minSalary,
    this.maxSalary,
    required this.tags,
    required this.status,
    this.createdAt,
    this.description,
  });

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    final stringValue = value.toString().replaceAll(',', '').trim();
    return double.tryParse(stringValue);
  }

  
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      jobId: map['job_id']?.toString() ?? map['id']?.toString() ?? map['pk']?.toString(),
      employerId: map['employer']?.toString() ?? map['employer_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'No Title',
      companyInfo: map['company_info']?.toString() ?? map['company']?.toString(),
      
      minSalary: _parseNullableDouble(map['min_salary']),
      maxSalary: _parseNullableDouble(map['max_salary']),
      
      tags: map['tags']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString(),
      description: map['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'employer': employerId,
      'title': title,
      'company_info': companyInfo,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'tags': tags,
      'status': status,
      'created_at': createdAt,
      'description': description,
    };
  }
}