class Application {
  final String applicationId;
  final String jobId;
  final String applicantId;
  final String phoneNumber;
  final double expectedSalary;
  final String cv_url;
  final String status;
  final String appliedAt;

  Application({
    required this.applicationId,
    required this.jobId,
    required this.applicantId,
    required this.phoneNumber,
    required this.expectedSalary,
    required this.cv_url,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      applicationId:
          map['application_id']?.toString() ?? map['id']?.toString() ?? '',
      jobId: map['job_id']?.toString() ?? '',
      applicantId: map['applicant_id']?.toString() ?? '',
      phoneNumber: map['phone_number']?.toString() ?? '',
      expectedSalary: (map['expected_salary'] is num)
          ? (map['expected_salary'] as num).toDouble()
          : double.tryParse(map['expected_salary']?.toString() ?? '0') ?? 0.0,
      cv_url: map['cv_url']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      appliedAt: map['applied_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'application_id': applicationId,
      'job_id': jobId,
      'applicant_id': applicantId,
      'phone_number': phoneNumber,
      'expected_salary': expectedSalary,
      'cv_url': cv_url,
      'status': status,
      'applied_at': appliedAt,
    };
  }
}
