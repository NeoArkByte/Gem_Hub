// lib/data/models/job_model.dart

class Job {
  final int? id;
  final String employerId;
  final String title;
  final String companyInfo;
  final String salary;
  final String tags;
  final int logoColor;
  final String status;
  final String? createdAt;

  Job({
    this.id,
    required this.employerId,
    required this.title,
    required this.companyInfo,
    required this.salary,
    required this.tags,
    required this.logoColor,
    required this.status,
    this.createdAt,
  });

  // DB eken ena data (Map) eka Job Object ekata harawanawa
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      employerId: map['employer_id'],
      title: map['title'],
      companyInfo: map['companyInfo'],
      salary: map['salary'],
      tags: map['tags'],
      logoColor: map['logoColor'],
      status: map['status'],
      createdAt: map['createdAt'],
    );
  }

  // Job Object eka ayeth DB ekata danna puluwan widihata Map karanawa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employer_id': employerId,
      'title': title,
      'companyInfo': companyInfo,
      'salary': salary,
      'tags': tags,
      'logoColor': logoColor,
      'status': status,
      'createdAt': createdAt,
    };
  }
}