import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sokrio_people_pulse/app/core/widgets/custom_app_bar.dart';
import '../providers/users_notifier_provider.dart';

import '../widgets/user_list_item.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/app_colors.dart';

// Main users list screen - shows all users with search and pagination
class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  // Controllers for scroll and search functionality
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set up scroll listener for pagination - load more when near bottom
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more users when we're 200px from the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(usersNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title:'Users',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: AppColors.surface,
                hintStyle: const TextStyle(color: AppColors.textTertiary),
              ),
              onChanged: (val) =>
                  ref.read(usersNotifierProvider.notifier).search(val),
            ),
          ),
        ),
      ),
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => _buildLoadingSkeleton(),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, style: const TextStyle(color: AppColors.error)),
              ElevatedButton(
                onPressed: () =>
                    ref.read(usersNotifierProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        success: (users, hasMore, isOffline, isLoadingMore,_) {
          if (users.isEmpty && !isLoadingMore) {
            return const Center(child: Text('No users found.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(usersNotifierProvider.notifier).refresh(),
            child: Column(
              children: [
                if (isOffline)
                  Container(
                    color: AppColors.offline,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'Offline Mode - Showing Cached Data \n Pull to Retry',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.surface, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: users.length +
                        1, // Always add 1 for loading or end message
                    itemBuilder: (context, index) {
                      if (index < users.length) {
                        return UserListItem(user: users[index]);
                      } else {
                        // Show loading indicator or end message
                        if (hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          // Show "No more data" message when pagination ends
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No more data',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(radius: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 10, color: AppColors.surface),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 10, color: AppColors.surface),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
