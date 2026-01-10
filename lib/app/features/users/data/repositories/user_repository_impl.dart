import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required UserLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<User>>> getPagedUsers(int page) async {
    try {

      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NoNetworkFailure('No Internet Connection'));
      }

      final remoteUsers = await _remoteDataSource.getUsers(page: page);
      await _localDataSource.upsertUsers(remoteUsers);
      return Right(remoteUsers);
    } on ServerException catch (e) {
      final message = e.message?.toLowerCase() ?? '';

      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('host') ||
          message.contains('socket') ||
          message.contains('connection refused') ||
          message.contains('hostlookup') ||
          message.contains('no address associated')) {
        return const Left(NoNetworkFailure('No Network Connection'));
      }

      if (e.message?.contains('403') == true) {
        return const Left(ForbiddenFailure(
            'Access Denied (403): The API blocked this request due to bot protection. Cached data will be shown if available.'));
      }
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserDetail(int id) async {
    try {
      // Try local first
      final localUser = await _localDataSource.getUserById(id);
      if (localUser != null) {
        return Right(localUser);
      }
      return const Left(CacheFailure('User not found locally'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsersLocal(String query) async {
    try {
      final results = await _localDataSource.searchUsers(query);
      return Right(results);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<User>> watchUsers() {
    return _localDataSource.watchUsers();
  }
}
