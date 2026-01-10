import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class GetPagedUsersUseCase {
  final UserRepository _repository;

  GetPagedUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call(int page) {
    return _repository.getPagedUsers(page);
  }
}
