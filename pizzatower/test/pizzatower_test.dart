import 'package:test/test.dart';
import 'package:pizzatower/pizzatower.dart';
import 'dart:io';

void main() {
  late File dbFile;
  late PizzaDatabase db;
  late TovarRepository tovarRepo;
  late CategoryRepository categoryRepo;

  setUp(() {
    dbFile = File('test_${DateTime.now().millisecondsSinceEpoch}.db');
    db = PizzaDatabase(dbFile.path);
    tovarRepo = TovarRepository(db);
    categoryRepo = CategoryRepository(db);
  });

  tearDown(() {
    db.close();
    if (dbFile.existsSync()) dbFile.deleteSync();
  });

  test('CRUD для товаров', () {
    // Create
    final tovar = Tovar(
      id: 'test_1',
      name: 'Маргарита',
      description: 'Классическая пицца',
      price: 450,
      categoryId: 'cat_pizza',
    );
    tovarRepo.insertTovar(tovar);
    
    // Read
    var tovars = tovarRepo.getAllTovars();
    expect(tovars.length, 1);
    expect(tovars.first.name, 'Маргарита');
    
    // Update
    final updated = Tovar(
      id: 'test_1',
      name: 'Маргарита Супер',
      description: 'С двойным сыром',
      price: 550,
      categoryId: 'cat_pizza',
    );
    tovarRepo.updateTovar(updated);
    
    final check = tovarRepo.getTovarById('test_1');
    expect(check?.price, 550);
    
    // Delete
    tovarRepo.deleteTovar('test_1');
    tovars = tovarRepo.getAllTovars();
    expect(tovars.length, 0);
  });
}