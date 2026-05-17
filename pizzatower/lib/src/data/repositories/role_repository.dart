import '../../domain/models/roles.dart';
import '../database.dart';

class RoleRepository {
  final PizzaDatabase _db;

  RoleRepository(this._db);

  int getNextId() {
    final result = _db.db.select('SELECT MAX(id) as max_id FROM roles');
    final maxId = result.first['max_id'] as int? ?? 0;
    return maxId + 1;
  }

  void insertRole(Role role) {
    _db.db.execute(
      'INSERT OR REPLACE INTO roles (id, name) VALUES (?, ?)',
      [int.parse(role.id), role.name],
    );
  }

  List<Role> getAllRoles() {
    final rows = _db.db.select('SELECT * FROM roles ORDER BY name');
    return rows.map((row) => Role.fromMap(row)).toList();
  }

  Role? getRoleById(String id) {
    final rows = _db.db.select('SELECT * FROM roles WHERE id = ?', [int.parse(id)]);
    return rows.isNotEmpty ? Role.fromMap(rows.first) : null;
  }

  void updateRole(Role role) {
    _db.db.execute(
      'UPDATE roles SET name = ? WHERE id = ?',
      [role.name, int.parse(role.id)],
    );
  }

  void deleteRole(String id) {
    final usersWithRole = _db.db.select(
      'SELECT COUNT(*) as count FROM users WHERE roleId = ?',
      [int.parse(id)],
    );
    final count = usersWithRole.first['count'] as int;
    
    if (count > 0) {
      throw Exception('Невозможно удалить роль: у $count пользователей эта роль');
    }
    
    _db.db.execute('DELETE FROM roles WHERE id = ?', [int.parse(id)]);
  }
}