import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'users_providers.dart';
import 'users_state.dart';
import '../../domain/entities/user.dart';
import '../../../../core/error/failures.dart';

class UsersNotifier extends StateNotifier<UsersState> {
  final Ref _ref;
  StreamSubscription<List<User>>? _usersSubscription;

  UsersNotifier(this._ref) : super(const UsersState.initial()) {
    _init();
  }

  void _init() {
    state = const UsersState.loading();
    // Subscribe to Drift Stream for offline-first data
    _usersSubscription =
        _ref.read(watchUsersUseCaseProvider).call().listen((users) {
      if (state is! Success) {
        state = UsersState.success(
          users: users,
          hasMore: true,
          isOffline: false,
        );
      } else {
        final currentState = state as Success;
        state = currentState.copyWith(users: users);
      }
    });

    // Initial fetch from remote
    fetchPage(1);
  }

  Future<void> fetchPage(int page) async {
    final currentState = state;
    final isFirstLoad = page == 1;

    if (currentState is Success && currentState.isLoadingMore) return;

    if (currentState is Success && !isFirstLoad) {
      state = currentState.copyWith(isLoadingMore: true);
    }

    final result = await _ref.read(getPagedUsersUseCaseProvider).call(page);

    result.fold(
      (failure) {
        if (isFirstLoad &&
            (currentState is! Success || currentState.users.isEmpty)) {
          if (failure is NoNetworkFailure) {
            state = UsersState.error(failure.message);
          } else {
            state = UsersState.error(failure.message);
          }
        } else if (currentState is Success) {
          state = currentState.copyWith(
            isLoadingMore: false,
            isOffline: true,
          );
        }
      },
      (newUsers) {
        if (state is Success) {
          final s = state as Success;
          state = s.copyWith(
            isLoadingMore: false,
            currentPage: page,
            hasMore: newUsers.length >= 10,
            isOffline: false,
          );
        }
      },
    );
  }

  Future<void> loadMore() async {
    if (state is Success) {
      final s = state as Success;
      if (s.hasMore && !s.isLoadingMore) {
        await fetchPage(s.currentPage + 1);
      }
    }
  }

  Future<void> refresh() async {
    await fetchPage(1);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      // Re-fetch all pages when clearing search
      await _refetchAllPages();
      return;
    }

    // Search through all cached data (not just current page)
    final result = await _ref.read(searchUsersLocalUseCaseProvider).call(query);
    result.fold(
      (failure) => null, // Handle search error if needed
      (results) {
        if (state is Success) {
          final s = state as Success;
          state = s.copyWith(
            users: results,
            hasMore: false, // Search results are final, no more pagination
            isOffline: false,
          );
        }
      },
    );
  }

  // Helper method to fetch all pages for search completeness
  Future<void> _refetchAllPages() async {
    List<User> allUsers = [];
    int page = 1;

    try {
      while (true) {
        final result = await _ref.read(getPagedUsersUseCaseProvider).call(page);
        final newUsers = result.getOrElse(() => <User>[]);

        if (newUsers.isEmpty) break;

        allUsers.addAll(newUsers);
        page++;

        // Stop if we have fewer than 10 users (indicates end)
        if (newUsers.length < 10) break;

        // Safety limit to prevent infinite loop
        if (page > 10) break;
      }

      // Update state with all fetched users
      if (state is Success) {
        final s = state as Success;
        state = s.copyWith(
          users: allUsers,
          hasMore: false,
          isOffline: false,
        );
      }
    } catch (e) {
      // Handle errors gracefully
      return;
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}
