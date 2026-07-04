import 'package:dio/dio.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';

class JobRepository {
  final Dio _dio;

  JobRepository(this._dio);

  Future<List<Job>> getPendingJobs() async {
    try {
      final response = await _dio.get(
        'jobs/',
        queryParameters: {'status': 'pending'},
      );

      if (response.statusCode == 200) {
        return _parseJobList(response.data['results']);
      }

      throw Exception('Failed to load pending jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }

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
        return _parseJobList(response.data['results']);
      }

      throw Exception('Failed to load approved jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }

Future<List<Job>> getMyJobs(String employerId) async {
  try {
    final response = await _dio.get('jobs/');
    
    // 💡 1. ෂුවර් නැත්නම් console එකේ බලන්න දත්ත එන්නේ කොහොමද කියලා
    // print(response.data);

    // 💡 2. මෙන්න වෙනස් වෙන්න ඕන තැන! (response.data['results'] කියලා දාන්න)
    // Django වලින් එන්නේ 'results' කියන key එක ඇතුලේ නම් මේක හරියටම වැඩ.
    final List<dynamic> data = response.data['results']; 
    
    // ආපු JSON Data ටික List<Job> එකකට හරවගන්නවා
    final List<Job> allJobs = data.map((json) => Job.fromMap(json)).toList();
    
    // Employer ID එක ගැලපෙන ඒවා විතරක් පෙරලා ගන්නවා
    final List<Job> myOnlyJobs = allJobs.where((job) => job.employerId == employerId).toList();
    
    return myOnlyJobs;
    
  } catch (e) {
    print("Error fetching jobs: $e");
    return [];
  }
}

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

  Future<bool> updateJob(Job job) async {
    try {
      final payload = Map<String, dynamic>.from(job.toMap());
      payload.removeWhere((key, value) => value == null);

      final response = await _dio.patch(
        'jobs/${job.jobId}/',
        data: payload,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    }
  }

  List<Job> _parseJobList(dynamic rawData) {
    final List data = rawData is List
        ? rawData
        : rawData is Map<String, dynamic>
            ? (rawData['results'] as List<dynamic>?) ?? []
            : [];

    return data.map((json) => Job.fromMap(json)).toList();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Error ${e.response?.statusCode}: ${e.response?.data}';
    }
    return 'Connection failed: ${e.message}';
  }

  Future<List<Job>> getAllJobs() async {
    try {
      final response = await _dio.get('jobs/');

      if (response.statusCode == 200) {
        return _parseJobList(response.data['results']);
      }

      throw Exception('Failed to load all jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    }
  }
}
