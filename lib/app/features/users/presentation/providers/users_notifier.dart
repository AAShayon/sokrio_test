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
      // Only update if we have data OR if we're in success state (offline mode)
      // Don't show empty success state during initial loading
      if (users.isNotEmpty && state is! Success) {
        state = UsersState.success(
          users: users,
          hasMore: true,
          isOffline: false,
        );
      } else if (state is Success) {
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
      (failure) async {
        if (failure is NoNetworkFailure && isFirstLoad) {
          // When no network, check local storage for cached data
          final cachedUsers =
              await _ref.read(searchUsersLocalUseCaseProvider).call('');

          cachedUsers.fold(
            (cacheFailure) {
              // No cached data available, show error
              state = UsersState.error(failure.message);
            },
            (users) {
              if (users.isNotEmpty) {
                // Show cached data with offline banner
                state = UsersState.success(
                  users: users,
                  hasMore: false,
                  isOffline: true,
                  isLoadingMore: false,
                  currentPage: 1,
                );
              } else {
                // No cached data, show error
                state = UsersState.error(failure.message);
              }
            },
          );
        } else if (currentState is Success) {
          state = currentState.copyWith(
            isLoadingMore: false,
            isOffline: true,
          );
        } else {
          // Other failures on first load
          state = UsersState.error(failure.message);
        }
      },
      (newUsers) {
        // Always update state when we get fresh data from network
        if (state is Success) {
          final s = state as Success;
          state = s.copyWith(
            isLoadingMore: false,
            currentPage: page,
            hasMore: newUsers.length >= 10,
            isOffline: false,
            users: newUsers,
          );
        } else {
          // First successful fetch from network
          state = UsersState.success(
            users: newUsers,
            hasMore: newUsers.length >= 10,
            isOffline: false,
            isLoadingMore: false,
            currentPage: page,
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
