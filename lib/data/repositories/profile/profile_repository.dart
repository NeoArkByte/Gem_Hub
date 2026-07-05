import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);


  Future<ProfileUser?> getProfileByUserId(String userId) async {
    try {
      final response = await _dio.get(
        'profiles/',
        queryParameters: {'profile_id': userId},
      );

      if (response.statusCode == 200) {
        final List? data = response.data['results'];
        if (data == null || data.isEmpty) return null;
        
        return ProfileUser.fromMap(data.first);
      }
      
      throw Exception('Failed to fetch profile by user ID');
    } on DioException catch (e) {
      debugPrint(_handleError(e));
      return null;
    }
  }

  
  Future<ProfileUser?> getProfileById(String id) async {
    try {
      final response = await _dio.get('profiles/$id/');

      if (response.statusCode == 200) {
        return ProfileUser.fromMap(response.data);
      }

      throw Exception('Failed to load profile details');
    } on DioException catch (e) {
      debugPrint(_handleError(e));
      return null;
    }
  }

  
  Future<bool> updateProfile(ProfileUser profile) async {
    try {      
      final response = await _dio.put(
        'profiles/${profile.id}/',
        data: profile.toMap(),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(_handleError(e));
      return false;
    }
  }

 
  Future<bool> partialUpdateProfile(
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(fields);
      payload.removeWhere((key, value) => value == null);

      final response = await _dio.patch(
        'profiles/$id/',
        data: payload,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(_handleError(e));
      return false;
    }
  }

 
  Future<bool> deleteProfile(String id) async {
    try {
      final response = await _dio.delete('profiles/$id/');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint(_handleError(e));
      return false;
    }
  }

  
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Error ${e.response?.statusCode}: ${e.response?.data}';
    }
    return 'Connection failed: ${e.message}';
  }
}