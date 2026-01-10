import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'users_state.freezed.dart';

@freezed
class UsersState with _$UsersState {
  const factory UsersState.initial() = Initial;
  const factory UsersState.loading() = Loading;
  const factory UsersState.success({
    required List<User> users,
    required bool hasMore,
    required bool isOffline,
    @Default(false) bool isLoadingMore,
    @Default(1) int currentPage,
  }) = Success;
  const factory UsersState.error(String message) = Error;
}
