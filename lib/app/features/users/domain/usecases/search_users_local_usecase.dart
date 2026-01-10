import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class SearchUsersLocalUseCase {
  final UserRepository _repository;

  SearchUsersLocalUseCase(this._repository);

  Future<Either<Failure, List<User>>> call(String query) {
    return _repository.searchUsersLocal(query);
  }
}
