import 'package:go_router/go_router.dart';
import '../../../features/users/presentation/screens/users_list_screen.dart';
import '../../../features/users/presentation/screens/user_detail_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/users',
    routes: [
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return UserDetailScreen(userId: id);
            },
          ),
        ],
      ),
    ],
  );
}
