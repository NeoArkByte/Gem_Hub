import 'package:dio/dio.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';

class GemRepository {
  final Dio _dio;

  GemRepository(this._dio);

  /// Fetches all gems
  Future<List<Gem>> getAllGems() async {
    try {
      final response = await _dio.get('gems/');
      final List data = response.data;
      return data.map((json) => Gem.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single gem
  Future<Gem> getGemById(String id) async {
    try {
      final response = await _dio.get('gems/$id/');
      return Gem.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST: Create a new gem listing
  Future<Gem> createGem(Gem gem) async {
    try {
      // We use toMap() which already converts status to lowercase for Django
      final response = await _dio.post('gems/', data: gem.toMap());
      return Gem.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH: Update an existing gem
  /// We use the gemId we parsed earlier to target the correct URL
  Future<Gem> updateGem(Gem gem) async {
    if (gem.gemId == null) throw 'Cannot update a gem without an ID';
    
    try {
      final response = await _dio.patch(
        'gems/${gem.gemId}/', 
        data: gem.toMap(),
      );
      return Gem.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE: Remove a gem listing
  Future<void> deleteGem(String id) async {
    try {
      await _dio.delete('gems/$id/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      // Django often returns errors in a 'detail' field or as a list of field errors
      final errorData = e.response?.data;
      return 'Error ${e.response?.statusCode}: $errorData';
    }
    return 'Connection failed: ${e.message}';
  }
}