import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'users_notifier.dart';
import 'users_state.dart';

final usersNotifierProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref);
});
