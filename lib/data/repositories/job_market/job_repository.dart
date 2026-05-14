import 'package:dio/dio.dart';
import 'package:job_market/data/models/job_market/job_model.dart';

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
        print('🔥 RAW DJANGO DATA: ${response.data}'); 
        final rawData = response.data;
        final List data = rawData is List
            ? rawData
            : rawData is Map<String, dynamic>
                ? (rawData['results'] as List<dynamic>?) ?? []
                : [];
        return data.map((json) => Job.fromMap(json)).toList();
      }
      throw Exception('Failed to load pending jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Job>> getApprovedJobs({String keyword = "", String category = ""}) async {
    try {
      final queryParams = <String, dynamic>{'status': 'approved'};
      
      if (keyword.isNotEmpty) {
        queryParams['search'] = keyword;
      }
      if (category.isNotEmpty && category != "All Jobs") {
        queryParams['category'] = category;
      }

      final response = await _dio.get('jobs/', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final rawData = response.data;
        final List data = rawData is List
            ? rawData
            : rawData is Map<String, dynamic>
                ? (rawData['results'] as List<dynamic>?) ?? []
                : [];
        return data.map((json) => Job.fromMap(json)).toList();
      }
      throw Exception('Failed to load jobs');
    } on DioException catch (e) {
      print(_handleError(e));
      return [];
    } catch (e) {
      print('🔥 JSON MAPPING ERROR එකක්: $e'); 
      return [];
    }
  }

  Future<bool> updateJobStatus(String id, String status) async {
    try {
      final path = 'jobs/$id/';
      print('PATCH $path -> status=$status');
      final response = await _dio.patch(
        path,
        data: {'status': status},
      );
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 204;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    } catch (e) {
      print('Unexpected error updating job status: $e');
      return false;
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
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print(_handleError(e));
      return false;
    } catch (e) {
      return false;
    }
  }

  
  String _handleError(DioException e) {
    if (e.response != null) {
      final errorData = e.response?.data;
      return 'Error ${e.response?.statusCode}: $errorData';
    }
    return 'Connection failed: ${e.message}';
  }
}