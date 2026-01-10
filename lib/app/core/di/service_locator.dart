import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_constants.dart';
import '../network/dio_client.dart';
import '../network/interceptors.dart';
import '../database/app_database.dart';
import '../../features/users/data/datasources/user_local_data_source.dart';
import '../../features/users/data/datasources/user_remote_data_source.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_paged_users_usecase.dart';
import '../../features/users/domain/usecases/get_user_detail_usecase.dart';
import '../../features/users/domain/usecases/search_users_local_usecase.dart';
import '../../features/users/domain/usecases/watch_users_usecase.dart';
import '../network/api_constants.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Reset GetIt to avoid conflicts during tests
  if (locator.isRegistered<Dio>(instance: locator)) {
    locator.reset();
  }
  // Core
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'x-api-key': AppConstants.apiKey,
      },
    ),
  );
  dio.interceptors.add(AppInterceptors());
  locator.registerLazySingleton(() => dio);
  locator.registerLazySingleton(() => DioClient(locator<Dio>()));

  // Database
  locator.registerLazySingleton(() => AppDatabase());

  // Data Sources
  locator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(locator<DioClient>()),
  );
  locator.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(locator<AppDatabase>()),
  );

  // Repository
  locator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: locator<UserRemoteDataSource>(),
      localDataSource: locator<UserLocalDataSource>(),
    ),
  );

  // Use Cases
  locator.registerLazySingleton(
      () => GetPagedUsersUseCase(locator<UserRepository>()));
  locator.registerLazySingleton(
      () => GetUserDetailUseCase(locator<UserRepository>()));
  locator.registerLazySingleton(
      () => SearchUsersLocalUseCase(locator<UserRepository>()));
  locator.registerLazySingleton(
      () => WatchUsersUseCase(locator<UserRepository>()));
}
