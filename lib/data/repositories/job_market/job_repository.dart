import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_market/job_model.dart';

class JobRepository {
  final String baseUrl = 'https://gem-hub-are5gkfgdqf4hyc4.southeastasia-01.azurewebsites.net/api/v1/';

  Future<List<Job>> getPendingJobs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/jobs/?status=pending'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Job.fromMap(json)).toList();
      }
      throw Exception('Failed to load pending jobs');
    } catch (e) {
      return [];
    }
  }

  Future<List<Job>> getApprovedJobs({String keyword = "", String category = ""}) async {
    try {
      final uri = Uri.parse('$baseUrl/jobs/').replace(queryParameters: {
        if (keyword.isNotEmpty) 'search': keyword,
        if (category.isNotEmpty && category != "All Jobs") 'category': category,
        'status': 'approved',
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Job.fromMap(json)).toList();
      }
      throw Exception('Failed to load jobs');
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateJobStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/jobs/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // Post New Job
  Future<bool> insertJob(Job job) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(job.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());

final pendingJobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getPendingJobs();
});

final approvedJobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getApprovedJobs();
});

final jobAdminViewModelProvider = Provider((ref) => JobAdminViewModel(ref));

class JobAdminViewModel {
  final Ref ref;
  JobAdminViewModel(this.ref);

  Future<bool> approveJob(String jobId) async {
    final repo = ref.read(jobRepositoryProvider);
    final success = await repo.updateJobStatus(jobId, 'approved');

    if (success) {
      ref.invalidate(pendingJobsProvider);
      ref.invalidate(approvedJobsProvider);
    }
    return success;
  }
}