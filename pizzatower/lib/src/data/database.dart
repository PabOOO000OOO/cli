import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class PizzaDatabase {
  final Database _db;

  PizzaDatabase(String path) : _db = sqlite3.open(path) {
    _createTables();
  }

  factory PizzaDatabase.inApp() {
    final path = p.join(Directory.current.path, 'pizzatower.db');
    return PizzaDatabase(path);
  }

  void _createTables() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        roleId INTEGER REFERENCES roles(id) ON DELETE SET NULL
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS tovars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        categoryId INTEGER REFERENCES categories(id) ON DELETE SET NULL
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER REFERENCES users(id) ON DELETE CASCADE,
        tovarId INTEGER REFERENCES tovars(id) ON DELETE CASCADE,
        kolvo INTEGER NOT NULL DEFAULT 1,
        UNIQUE(userId, tovarId)
      );
    ''');

    _insertInitialData();
  }

  void _insertInitialData() {
    _db.execute('''
      INSERT OR IGNORE INTO roles (id, name) VALUES 
        (1, 'Администратор'),
        (2, 'Пользователь')
    ''');

    _db.execute('''
      INSERT OR IGNORE INTO categories (id, name) VALUES 
        (1, 'Пицца'),
        (2, 'Напитки'),
        (3, 'Десерты')
    ''');

    _db.execute('''
      INSERT OR IGNORE INTO users (id, name, password, phone, roleId) VALUES 
        (1, 'Иван Петров', 'pass123', '+7(999)123-45-67', 2),
        (2, 'Админ', 'admin123', '+7(999)000-00-00', 1)
    ''');
  }

  Database get db => _db;

  void close() => _db.dispose();
}