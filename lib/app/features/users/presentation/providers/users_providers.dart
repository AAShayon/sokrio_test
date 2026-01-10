import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_paged_users_usecase.dart';
import '../../domain/usecases/get_user_detail_usecase.dart';
import '../../domain/usecases/search_users_local_usecase.dart';
import '../../domain/usecases/watch_users_usecase.dart';
import '../../../../core/di/service_locator.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => locator<UserRepository>());

final getPagedUsersUseCaseProvider = Provider<GetPagedUsersUseCase>(
  (ref) => locator<GetPagedUsersUseCase>(),
);

final getUserDetailUseCaseProvider = Provider<GetUserDetailUseCase>(
  (ref) => locator<GetUserDetailUseCase>(),
);

final searchUsersLocalUseCaseProvider = Provider<SearchUsersLocalUseCase>(
  (ref) => locator<SearchUsersLocalUseCase>(),
);

final watchUsersUseCaseProvider = Provider<WatchUsersUseCase>(
  (ref) => locator<WatchUsersUseCase>(),
);
