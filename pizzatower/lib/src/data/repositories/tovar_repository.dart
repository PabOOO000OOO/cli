import '../../domain/models/tovars.dart';
import '../database.dart';

class TovarRepository {
  final PizzaDatabase _db;

  TovarRepository(this._db);

  int getNextId() {
    final result = _db.db.select('SELECT MAX(id) as max_id FROM tovars');
    final maxId = result.first['max_id'] as int? ?? 0;
    return maxId + 1;
  }

  void insertTovar(Tovar tovar) {
    _db.db.execute(
      'INSERT OR REPLACE INTO tovars (id, name, description, price, categoryId) VALUES (?, ?, ?, ?, ?)',
      [int.parse(tovar.id), tovar.name, tovar.description, tovar.price, int.parse(tovar.categoryId)],
    );
  }

  List<Tovar> getAllTovars() {
    final rows = _db.db.select('SELECT * FROM tovars ORDER BY name');
    return rows.map((row) => Tovar.fromMap(row)).toList();
  }

  Tovar? getTovarById(String id) {
    final rows = _db.db.select('SELECT * FROM tovars WHERE id = ?', [int.parse(id)]);
    return rows.isNotEmpty ? Tovar.fromMap(rows.first) : null;
  }

  List<Tovar> getTovarsByCategory(String categoryId) {
    final rows = _db.db.select(
      'SELECT * FROM tovars WHERE categoryId = ? ORDER BY name',
      [int.parse(categoryId)],
    );
    return rows.map((row) => Tovar.fromMap(row)).toList();
  }

  void updateTovar(Tovar tovar) {
    _db.db.execute(
      'UPDATE tovars SET name = ?, description = ?, price = ?, categoryId = ? WHERE id = ?',
      [tovar.name, tovar.description, tovar.price, int.parse(tovar.categoryId), int.parse(tovar.id)],
    );
  }

  void deleteTovar(String id) {
    _db.db.execute('DELETE FROM tovars WHERE id = ?', [int.parse(id)]);
  }
}