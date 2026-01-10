import 'package:flutter/material.dart';

// Centralized color definitions for the app
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2196F3); // Blue
  static const primaryLight = Color(0xFFE3F2FD); // Light Blue

  // Background Colors
  static const background = Color(0xFFF5F5F5); // Light Gray
  static const surface = Color(0xFFFFFFFF); // White
  static const card = Color(0xFFFFFFFF); // White

  // Text Colors
  static const textPrimary = Color(0xFF1F2937); // Dark Gray
  static const textSecondary = Color(0xFF6B7280); // Medium Gray
  static const textTertiary = Color(0xFF90A4AE); // Light Gray

  // Status Colors
  static const success = Color(0xFF10B981); // Green
  static const error = Color(0xFFEF4444); // Red
  static const warning = Color(0xFFF59E0B); // Amber
  static const info = Color(0xFF3B82F6); // Blue

  // Border Colors
  static const border = Color(0xFFE5E7EB); // Light Gray
  static const borderLight = Color(0xFFF0F0F0); // Very Light Gray

  // Special Colors
  static const offline = Color(0xFFFF9800); // Orange
  static const shimmerBase = Color(0xFFE0E0E0); // Light Gray
  static const shimmerHighlight = Color(0xFFF5F5F5); // White

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
