class Application {
  final int? id;
  final int jobId;
  final int applicantId;
  final String status; // 'Pending', 'Approved', or 'Declined'

  Application({
    this.id,
    required this.jobId,
    required this.applicantId,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'applicant_id': applicantId,
      'status': status,
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as int?,
      jobId: map['job_id'] as int,
      applicantId: map['applicant_id'] as int,
      status: map['status'] as String,
    );
  }
}