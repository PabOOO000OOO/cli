String? validateNotEmpty(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName не может быть пустым.';
  }
  return null;
}

String? validatePositiveInt(int value, String fieldName) {
  if (value <= 0) {
    return '$fieldName должно быть больше 0.';
  }
  return null;
}

String? validatePositiveDouble(double value, String fieldName) {
  if (value <= 0) {
    return '$fieldName должно быть больше 0.';
  }
  return null;
}