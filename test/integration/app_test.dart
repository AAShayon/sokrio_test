import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/entities/user.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/repositories/user_repository.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/usecases/get_paged_users_usecase.dart';
import 'package:sokrio_people_pulse/app/features/users/domain/usecases/search_users_local_usecase.dart';

import 'app_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockUserRepository;
  late GetPagedUsersUseCase getPagedUsersUseCase;
  late SearchUsersLocalUseCase searchUsersLocalUseCase;

  setUp(() {
    mockUserRepository = MockUserRepository();
    getPagedUsersUseCase = GetPagedUsersUseCase(mockUserRepository);
    searchUsersLocalUseCase = SearchUsersLocalUseCase(mockUserRepository);
  });

  group('Repository Integration Tests', () {
    test('should fetch users successfully', () async {
      // Arrange
      final testUsers = [
        TestUser(
          id: 1,
          email: 'george.bluth@reqres.in',
          firstName: 'George',
          lastName: 'Bluth',
          avatar: 'https://reqres.in/img/faces/1-image.jpg',
        ),
        TestUser(
          id: 2,
          email: 'janet.weaver@reqres.in',
          firstName: 'Janet',
          lastName: 'Weaver',
          avatar: 'https://reqres.in/img/faces/2-image.jpg',
        ),
      ];

      when(mockUserRepository.getPagedUsers(1))
          .thenAnswer((_) async => Right(testUsers));

      // Act
      final result = await getPagedUsersUseCase(1);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (users) {
          expect(users.length, 2);
          expect(users[0].firstName, 'John');
        },
      );
      verify(mockUserRepository.getPagedUsers(1)).called(1);
    });

    test('should search users by name', () async {
      // Arrange
      final testUsers = [
        TestUser(
          id: 1,
          email: 'george.bluth@reqres.in',
          firstName: 'George',
          lastName: 'Bluth',
          avatar: 'https://reqres.in/img/faces/1-image.jpg',
          ),
        TestUser(
          id: 2,
          email: 'janet.weaver@reqres.in',
          firstName: 'Janet',
          lastName: 'Weaver',
          avatar: 'https://reqres.in/img/faces/2-image.jpg',
        ),
      ];

      when(mockUserRepository.searchUsersLocal('John'))
          .thenAnswer((_) async => Right([testUsers[0]]));

      // Act
      final result = await searchUsersLocalUseCase('John');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (users) {
          expect(users.length, 1);
          expect(users[0].firstName, 'John');
        },
      );
      verify(mockUserRepository.searchUsersLocal('John')).called(1);
    });

    test('should search users by email', () async {
      // Arrange
      final testUsers = [
        TestUser(
            id: 1,
            email: 'john@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatar: 'avatar1'),
      ];

      when(mockUserRepository.searchUsersLocal('john@example.com'))
          .thenAnswer((_) async => Right(testUsers));

      // Act
      final result = await searchUsersLocalUseCase('john@example.com');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (users) {
          expect(users.length, 1);
          expect(users[0].email, 'john@example.com');
        },
      );
      verify(mockUserRepository.searchUsersLocal('john@example.com')).called(1);
    });

    test('should handle empty search results', () async {
      // Arrange
      when(mockUserRepository.searchUsersLocal('NonExistent'))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await searchUsersLocalUseCase('NonExistent');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (users) {
          expect(users.isEmpty, true);
        },
      );
      verify(mockUserRepository.searchUsersLocal('NonExistent')).called(1);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(mockUserRepository.getPagedUsers(1))
          .thenAnswer((_) async => throw Exception('Network error'));

      // Act & Assert
      expect(() async => await getPagedUsersUseCase(1), throwsException);
    });
  });
}

// Test implementation of User abstract class
class TestUser extends User {
  @override
  final int id;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String avatar;

  const TestUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  @override
  List<Object?> get props => [id, email, firstName, lastName, avatar];
}
