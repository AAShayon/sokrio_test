import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> upsertUsers(List<UserModel> users);
  Stream<List<UserModel>> watchUsers();
  Future<List<UserModel>> searchUsers(String query);
  Future<UserModel?> getUserById(int id);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final AppDatabase _db;

  UserLocalDataSourceImpl(this._db);

  @override
  Future<void> upsertUsers(List<UserModel> users) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.users,
        users.map((u) => UsersCompanion.insert(
              id: Value(u.id),
              email: u.email,
              firstName: u.firstName,
              lastName: u.lastName,
              avatar: u.avatar,
            )),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Stream<List<UserModel>> watchUsers() {
    return _db.select(_db.users).watch().map((rows) {
      return rows.map((row) => UserModel(
        id: row.id,
        email: row.email,
        firstName: row.firstName,
        lastName: row.lastName,
        avatar: row.avatar,
      )).toList();
    });
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final results = await (_db.select(_db.users)
          ..where((t) =>
              t.firstName.contains(query) | t.lastName.contains(query) | t.email.contains(query)))
        .get();

    return results.map((row) => UserModel(
      id: row.id,
      email: row.email,
      firstName: row.firstName,
      lastName: row.lastName,
      avatar: row.avatar,
    )).toList();
  }

  @override
  Future<UserModel?> getUserById(int id) async {
    final query = _db.select(_db.users)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return UserModel(
      id: row.id,
      email: row.email,
      firstName: row.firstName,
      lastName: row.lastName,
      avatar: row.avatar,
    );
  }
}
