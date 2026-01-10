import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sokrio_people_pulse/app/core/config/app_config.dart';
import 'app/core/di/service_locator.dart';
import 'app/core/config/router/app_router.dart';
import 'app/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Main entry point - need to initialize services before running the app
void main() async {
  // Important: Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // Set up dependency injection before we run anything
  await setupLocator();

  // Run the app with Riverpod scope for state management
  runApp(const ProviderScope(child: MyApp()));
}

// Separate entry point for integration tests
Future<void> testMain() async {
  // Important: Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // Reset and set up dependency injection for testing
  await locator.reset();
  await setupLocator();

  // Run the app with Riverpod scope for state management
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtil makes responsive design easier - handles different screen sizes
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Base design size
      minTextAdapt: true, // Scale text appropriately
      splitScreenMode: true, // Handle split screen situations
      builder: (_, __) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false, // Clean app without debug banner
            theme: AppTheme.lightTheme, // Light theme for now
            routerConfig: AppRouter.router, // GoRouter for navigation
          ),
        );
      },
    );
  }
}
