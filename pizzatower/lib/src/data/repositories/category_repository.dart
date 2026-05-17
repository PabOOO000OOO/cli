import '../../domain/models/categories.dart';
import '../database.dart';

class CategoryRepository {
  final PizzaDatabase _db;

  CategoryRepository(this._db);

  int getNextId() {
    final result = _db.db.select('SELECT MAX(id) as max_id FROM categories');
    final maxId = result.first['max_id'] as int? ?? 0;
    return maxId + 1;
  }

  void insertCategory(Category category) {
    _db.db.execute(
      'INSERT OR REPLACE INTO categories (id, name) VALUES (?, ?)',
      [int.parse(category.id), category.name],
    );
  }

  List<Category> getAllCategories() {
    final rows = _db.db.select('SELECT * FROM categories ORDER BY name');
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  Category? getCategoryById(String id) {
    final rows = _db.db.select('SELECT * FROM categories WHERE id = ?', [int.parse(id)]);
    return rows.isNotEmpty ? Category.fromMap(rows.first) : null;
  }

  void updateCategory(Category category) {
    _db.db.execute(
      'UPDATE categories SET name = ? WHERE id = ?',
      [category.name, int.parse(category.id)],
    );
  }

  void deleteCategory(String id) {
    _db.db.execute('DELETE FROM categories WHERE id = ?', [int.parse(id)]);
  }
}