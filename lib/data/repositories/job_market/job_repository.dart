import 'package:dio/dio.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';

class JobRepository {
  final Dio _dio;

  JobRepository(this._dio);

  /// ✅ Get Pending Jobs (Admin)
  Future<List<Job>> getPendingJobs() async {
    try {
      final response = await _dio.get(
        'jobs/',
        queryParameters: {'status': 'pending'},
      );

      if (response.statusCode == 200) {
        return _parseJobList(response.data);
      }

      throw Exception('Failed to load pending jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }

  /// ✅ Get Approved Jobs (Marketplace)
  Future<List<Job>> getApprovedJobs({
    String keyword = "",
    String category = "",
    String location = "",
    double? minSalary,
    double? maxSalary,
  }) async {
    try {
      final queryParams = <String, dynamic>{'status': 'approved'};

      if (keyword.isNotEmpty) {
        queryParams['search'] = keyword;
      }

      if (category.isNotEmpty && category != "All Jobs") {
        queryParams['category'] = category;
      }

      if (location.isNotEmpty && location != "All Locations") {
        queryParams['location'] = location;
      }

      if (minSalary != null) {
        queryParams['min_salary'] = minSalary.toInt();
      }

      if (maxSalary != null) {
        queryParams['max_salary'] = maxSalary.toInt();
      }

      final response =
          await _dio.get('jobs/', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return _parseJobList(response.data);
      }

      throw Exception('Failed to load approved jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }

  /// ✅ NEW: Get Logged-in Employer Jobs
  /// ✅ NEW: Get Logged-in Employer Jobs (Filtered by ID)
  Future<List<Job>> getMyJobs(String employerId) async {
    try {
      final response = await _dio.get(
        'jobs/', // 💡 වෙනම URL එකක් ඕනේ නෑ, Main එකටම යවනවා
        queryParameters: {
          'employerId': employerId, // 🚧 Django එකේ model එකේ නම employer_id නම් මේක 'employer_id' කරන්න
        },
      );

      if (response.statusCode == 200) {
        return _parseJobList(response.data);
      }

      throw Exception('Failed to load my jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }

  /// ✅ Insert New Job
  Future<bool> insertJob(Job job) async {
    try {
      final payload = Map<String, dynamic>.from(job.toMap());

      payload.removeWhere((key, value) => value == null);

      final response = await _dio.post(
        'jobs/',
        data: payload,
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    }
  }

  /// ✅ Update Job Status
  Future<bool> updateJobStatus(String id, String status) async {
    try {
      final response = await _dio.patch(
        'jobs/$id/',
        data: {'status': status},
      );

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    }
  }

  /// ✅ NEW: Delete Job
  Future<bool> deleteJob(String id) async {
    try {
      final response = await _dio.delete(
        'jobs/$id/',
      );

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    }
  }

  /// ✅ Helper: Handle Django Pagination / List Response
  List<Job> _parseJobList(dynamic rawData) {
    final List data = rawData is List
        ? rawData
        : rawData is Map<String, dynamic>
            ? (rawData['results'] as List<dynamic>?) ?? []
            : [];

    return data.map((json) => Job.fromMap(json)).toList();
  }

  /// ✅ Error Handler
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Error ${e.response?.statusCode}: ${e.response?.data}';
    }
    return 'Connection failed: ${e.message}';
  }
}