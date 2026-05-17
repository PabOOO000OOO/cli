import 'dart:io';
import '../domain/validators/validators.dart';

String askString(String prompt, String fieldName) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync()?.trim() ?? '';
    final error = validateNotEmpty(input, fieldName);
    if (error == null) return input;
    stdout.writeln('Ошибка: $error');
  }
}

int askPositiveInt(String prompt, String fieldName) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync()?.trim() ?? '';
    final int? value = int.tryParse(input);
    if (value == null) {
      stdout.writeln('Ошибка: введите целое число.');
      continue;
    }
    final error = validatePositiveInt(value, fieldName);
    if (error == null) return value;
    stdout.writeln('Ошибка: $error');
  }
}

double askPositiveDouble(String prompt, String fieldName) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync()?.trim() ?? '';
    final double? value = double.tryParse(input);
    if (value == null) {
      stdout.writeln('Ошибка: введите число.');
      continue;
    }
    final error = validatePositiveDouble(value, fieldName);
    if (error == null) return value;
    stdout.writeln('Ошибка: $error');
  }
}