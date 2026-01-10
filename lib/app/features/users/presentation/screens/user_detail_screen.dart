import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_providers.dart';
import '../../domain/entities/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'User Details'),
      body: FutureBuilder(
        future: ref.read(getUserDetailUseCaseProvider).call(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final result = snapshot.data!;
            return result.fold(
              (failure) => Center(child: Text(failure.message)),
              (user) => _buildDetail(user),
            );
          }

          return const Center(child: Text('User not found.'));
        },
      ),
    );
  }

  Widget _buildDetail(User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Hero(
            tag: 'user-avatar-${user.id}',
            child: CircleAvatar(
              radius: 80,
              backgroundImage: CachedNetworkImageProvider(user.avatar),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
        ],
      ),
    );
  }
}
