// lib/data/repositories/job_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart'; // Path eka check karanna
import 'package:job_market/data/models/job_model.dart';

// 👇 Riverpod Provider eka (App eke wena than walin mekata katha karanne meken)
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(DatabaseHelper());
});

class JobRepository {
  final DatabaseHelper _dbHelper;

  JobRepository(this._dbHelper);

  // 1. Pending jobs tika ganna (Admin screen ekata)
  Future<List<Job>> getPendingJobs() async {
    final data = await _dbHelper.getPendingJobs();
    // Map eken ena ewa Job Model ekata convert karanawa
    return data.map((map) => Job.fromMap(map)).toList(); 
  }

  // 2. Jobs search/filter karanna (Marketplace feed ekata)
  Future<List<Job>> searchAndFilterJobs(String keyword, String category) async {
    final data = await _dbHelper.searchAndFilterJobs(keyword, category);
    return data.map((map) => Job.fromMap(map)).toList();
  }

  // 3. Job status update karanna (Approve/Reject)
  Future<void> updateJobStatus(int id, String status) async {
    await _dbHelper.updateJobStatus(id, status);
  }

  // 4. Aluth job ekak post karanna
  Future<void> insertJob(Job job) async {
    await _dbHelper.insertJob(job.toMap());
  }
}