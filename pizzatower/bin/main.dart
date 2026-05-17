import 'package:pizzatower/pizzatower.dart';

void main(List<String> arguments) {
  final db = PizzaDatabase.inApp();
  try {
    runMenu(db);
  } finally {
    db.close();
  }
}