import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'users_providers.dart';
import 'users_state.dart';
import '../../domain/entities/user.dart';
import '../../../../core/error/failures.dart';

class UsersNotifier extends StateNotifier<UsersState> {
  final Ref _ref;
  StreamSubscription<List<User>>? _usersSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isCurrentlyOnline = true;

  UsersNotifier(this._ref) : super(const UsersState.initial()) {
    _init();
  }

  void _init() {
    state = const UsersState.loading();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });

    _checkInitialConnectivity();

    // Subscribe to Drift Stream for offline-first data
    _usersSubscription =
        _ref.read(watchUsersUseCaseProvider).call().listen((users) {
      if (users.isNotEmpty && state is! Success) {
        state = UsersState.success(
          users: users,
          hasMore: true,
          isOffline: !_isCurrentlyOnline,
        );
      } else if (state is Success) {
        final currentState = state as Success;
        state = currentState.copyWith(users: users);
      }
    });
    fetchPage(1);
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    _isCurrentlyOnline = result != ConnectivityResult.none;
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;

    if (_isCurrentlyOnline != isOnline) {
      _isCurrentlyOnline = isOnline;

      if (isOnline) {
        if (state is Success) {
          refresh();
        }
      } else {
        if (state is Success) {
          final currentState = state as Success;
          if (currentState.users.isNotEmpty) {
            state = currentState.copyWith(isOffline: true);
          }
        }
      }
    }
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
          final cachedUsers =
              await _ref.read(searchUsersLocalUseCaseProvider).call('');

          cachedUsers.fold(
            (cacheFailure) {
              state = UsersState.error(cacheFailure.message);
            },
            (users) {
              if (users.isNotEmpty) {
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
            isOffline: !_isCurrentlyOnline,
          );
        } else {
          state = UsersState.error(failure.message);
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
            users: newUsers,
          );
        } else {
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
      await _refetchAllPages();
      return;
    }

    final result = await _ref.read(searchUsersLocalUseCaseProvider).call(query);
    result.fold(
      (failure) => null,
      (results) {
        if (state is Success) {
          final s = state as Success;
          state = s.copyWith(
            users: results,
            hasMore: false,
            isOffline: !_isCurrentlyOnline,
          );
        }
      },
    );
  }

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

        if (newUsers.length < 10) break;

        if (page > 10) break;
      }

      if (state is Success) {
        final s = state as Success;
        state = s.copyWith(
          users: allUsers,
          hasMore: false,
          isOffline: !_isCurrentlyOnline,
        );
      }
    } catch (e) {
      return;
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
