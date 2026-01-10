import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getPagedUsers(int page);
  Future<Either<Failure, User>> getUserDetail(int id);
  Future<Either<Failure, List<User>>> searchUsersLocal(String query);
  Stream<List<User>> watchUsers();
}
