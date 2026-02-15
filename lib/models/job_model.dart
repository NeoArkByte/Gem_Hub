class Job {
  final int? id;
  final String title;
  final String description;
  final int postedBy; 
  final String status; 

  Job({
    this.id,
    required this.title,
    required this.description,
    required this.postedBy,
    this.status = 'Open',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posted_by': postedBy,
      'status': status,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      postedBy: map['posted_by'] as int,
      status: map['status'] as String,
    );
  }
}