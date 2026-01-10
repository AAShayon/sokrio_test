import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:sokrio_people_pulse/app/features/users/data/models/user_model.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/entities/user.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/repositories/user_repository.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/usecases/get_paged_users_usecase.dart';
import 'package:sokrio_people_pulse/app/core/error/failures.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<Either<Failure, List<User>>> getPagedUsers(int page) {
    if (page == 1) {
      return Future.value(const Right([
        UserModel(
          id: 1,
          email: 'george.bluth@reqres.in',
          firstName: 'George',
          lastName: 'Bluth',
          avatar: 'https://reqres.in/img/faces/1-image.jpg',
        ),
        UserModel(
          id: 2,
          email: 'janet.weaver@reqres.in',
          firstName: 'Janet',
          lastName: 'Weaver',
          avatar: 'https://reqres.in/img/faces/2-image.jpg',
        ),
      ]));
    } else if (page == 2) {
      return Future.value(const Right([
        UserModel(
          id: 3,
          email: 'emma.wong@reqres.in',
          firstName: 'Emma',
          lastName: 'Wong',
          avatar: 'https://reqres.in/img/faces/3-image.jpg',
        ),
      ]));
    } else {
      return Future.value(const Right([]));
    }
  }

  @override
  Future<Either<Failure, User>> getUserDetail(int id) {
    if (id == 1) {
      return Future.value(const Right(UserModel(
        id: 1,
        email: 'george.bluth@reqres.in',
        firstName: 'George',
        lastName: 'Bluth',
        avatar: 'https://reqres.in/img/faces/1-image.jpg',
      )));
    }
    return Future.value(const Left(ServerFailure('User not found')));
  }

  @override
  Future<Either<Failure, List<User>>> searchUsersLocal(String query) {
    return Future.value(const Right([]));
  }

  @override
  Stream<List<User>> watchUsers() {
    return Stream.value([]);
  }
}

void main() {
  late GetPagedUsersUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetPagedUsersUseCase(mockRepository);
  });

  test('should get users from repository when page is valid', () async {
    // Arrange
    const page = 1;

    // Act
    final result = await useCase(page);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected success but got failure'),
      (users) {
        expect(users.length, 2);
        expect(users.first.id, 1);
        expect(users.first.email, 'george.bluth@reqres.in');
      },
    );
  });

  test('should return empty list when no more users available', () async {
    // Arrange
    const page = 3;

    // Act
    final result = await useCase(page);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected success but got failure'),
      (users) => expect(users.isEmpty, true),
    );
  });

  test('should handle different page numbers correctly', () async {
    // Arrange
    const page = 2;

    // Act
    final result = await useCase(page);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected success but got failure'),
      (users) {
        expect(users.length, 1);
        expect(users.first.id, 3);
        expect(users.first.firstName, 'Emma');
      },
    );
  });
}
