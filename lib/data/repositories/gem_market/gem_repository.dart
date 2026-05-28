import 'package:dio/dio.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';

class GemRepository {
  final Dio _dio;

  GemRepository(this._dio);

  Future<List<Gem>> getAllGems() async {
    try {
      final response = await _dio.get('gems/');
      final List data = response.data;
      return data.map((json) => Gem.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Gem>> getAllGemsByUserId(String userId) async {
    try {
      final response = await _dio.get('gems/by_owner/$userId/');
      final List data = response.data;
      return data.map((json) => Gem.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Gem> getGemById(String id) async {
    try {
      final response = await _dio.get('gems/$id/');
      return Gem.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Gem> createGem(Gem gem) async {
    try {
      final response = await _dio.post('gems/', data: gem.toMap());
      return Gem.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  Future<void> deleteGem(String id) async {
    try {
      await _dio.delete(
        'gems/$id/',
        options: Options(
          headers: {
            'X-HTTP-Method-Override': 'DELETE',
            'X-Method-Override': 'DELETE',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
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
