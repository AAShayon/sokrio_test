import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class GetUserDetailUseCase {
  final UserRepository _repository;

  GetUserDetailUseCase(this._repository);

  Future<Either<Failure, User>> call(int id) {
    return _repository.getUserDetail(id);
  }
}
