import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class WatchUsersUseCase {
  final UserRepository _repository;

  WatchUsersUseCase(this._repository);

  Stream<List<User>> call() {
    return _repository.watchUsers();
  }
}
