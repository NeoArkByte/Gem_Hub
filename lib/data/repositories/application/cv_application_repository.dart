import 'package:dio/dio.dart';

class CvApplicationRepository {
  final Dio _dio;

  CvApplicationRepository(this._dio);

  Future<bool> submitApplication({
    required String jobId,
    required String applicantId,
    required String cvFilePath, 
    
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'job': jobId,
        'applicant': applicantId,
        
        'cv': await MultipartFile.fromFile(
          cvFilePath,
          filename: cvFilePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        'applications/', 
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('DioException: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }
}