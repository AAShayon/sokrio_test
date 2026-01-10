
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers({required int page, int perPage = 10});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _client;

  UserRemoteDataSourceImpl(this._client);

  @override
  Future<List<UserModel>> getUsers({required int page, int perPage = 10}) async {
    final response = await _client.get(
      ApiConstants.usersEndpoint,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final List data = response.data['data'];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }
}
