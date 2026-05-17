import '../../domain/models/users.dart';
import '../database.dart';

class UserRepository {
  final PizzaDatabase _db;

  UserRepository(this._db);

  int getNextId() {
    final result = _db.db.select('SELECT MAX(id) as max_id FROM users');
    final maxId = result.first['max_id'] as int? ?? 0;
    return maxId + 1;
  }

  void insertUser(User user) {
    _db.db.execute(
      'INSERT OR REPLACE INTO users (id, name, password, phone, roleId) VALUES (?, ?, ?, ?, ?)',
      [int.parse(user.id), user.name, user.password, user.phone, int.parse(user.roleId)],
    );
  }

  List<User> getAllUsers() {
    final rows = _db.db.select('SELECT * FROM users ORDER BY name');
    return rows.map((row) => User.fromMap(row)).toList();
  }

  User? getUserById(String id) {
    final rows = _db.db.select('SELECT * FROM users WHERE id = ?', [int.parse(id)]);
    return rows.isNotEmpty ? User.fromMap(rows.first) : null;
  }

  User? getUserByPhone(String phone) {
    final rows = _db.db.select('SELECT * FROM users WHERE phone = ?', [phone]);
    return rows.isNotEmpty ? User.fromMap(rows.first) : null;
  }

  void updateUser(User user) {
    _db.db.execute(
      'UPDATE users SET name = ?, password = ?, phone = ?, roleId = ? WHERE id = ?',
      [user.name, user.password, user.phone, int.parse(user.roleId), int.parse(user.id)],
    );
  }

  void deleteUser(String id) {
    _db.db.execute('DELETE FROM users WHERE id = ?', [int.parse(id)]);
  }
}