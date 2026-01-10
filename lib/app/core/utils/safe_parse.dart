
// lib/app/core/utils/safe_parse.dart
T safeParse<T>(dynamic value, T defaultValue) {
  if (value == null) return defaultValue;
  if (value is T) return value;
  
  if (value is String) {
    if (T == int) return (int.tryParse(value) ?? defaultValue) as T;
    if (T == double) return (double.tryParse(value) ?? defaultValue) as T;
  }
  if (value is num) {
    if (T == int) return value.toInt() as T;
    if (T == double) return value.toDouble() as T;
    if (T == String) return value.toString() as T;
  }
  return defaultValue;
}
