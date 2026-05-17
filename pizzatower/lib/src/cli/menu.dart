import 'dart:io';
import '../data/database.dart';
import '../data/repositories/tovar_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/role_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../domain/models/tovars.dart';
import '../domain/models/users.dart';
import '../domain/models/cart.dart';
import '../domain/models/roles.dart';
import '../domain/models/categories.dart';
import 'input_helper.dart';

void runMenu(PizzaDatabase db) {
  final tovarRepo = TovarRepository(db);
  final userRepo = UserRepository(db);
  final categoryRepo = CategoryRepository(db);
  final roleRepo = RoleRepository(db);
  final cartRepo = CartRepository(db);
  
  String? currentUserId;
  
  while (true) {
    stdout.writeln('''
          PIZZA TOWER CLI 
   1 - Войти как пользователь          
   2 - Регистрация                     
   3 - Список товаров                  
   4 - Категории товаров               
   5 - Моя корзина    
   6 - Оформить заказ                  
   7 - Управление товарами (админ)     
   8 - Управление пользователями (админ)
   9 - ПОКАЗАТЬ ВСЁ ИЗ БД              
   0 - Выход                           
Выберите пункт:''');

    final choice = stdin.readLineSync()?.trim() ?? '';
    switch (choice) {
      case '1':
        currentUserId = _login(userRepo);
        break;
      case '2':
        _register(userRepo, roleRepo);
        break;
      case '3':
        _listTovars(tovarRepo, categoryRepo);
        break;
      case '4':
        _listCategories(categoryRepo, tovarRepo);
        break;
      case '5':
        if (currentUserId != null) {
          _showCart(cartRepo, tovarRepo, currentUserId);
        } else {
          stdout.writeln('Сначала войдите в систему!');
        }
        break;
      case '6':
        if (currentUserId != null) {
          _checkout(cartRepo, currentUserId);
        } else {
          stdout.writeln('Сначала войдите в систему!');
        }
        break;
      case '7':
        _adminTovarMenu(tovarRepo, categoryRepo);
        break;
      case '8':
        _adminUserMenu(userRepo, roleRepo);
        break;
      case '9':
        _showAllFromDb(tovarRepo, categoryRepo, userRepo, roleRepo, cartRepo);
        break;
      case '0':
        stdout.writeln('До свидания!');
        return;
      default:
        stdout.writeln('Неизвестная команда.');
    }
    stdout.writeln();
  }
}

String? _login(UserRepository userRepo) {
  stdout.writeln('Вход в систему');
  final phone = askString('Телефон: ', 'Телефон');
  final password = askString('Пароль: ', 'Пароль');
  
  try {
    final user = userRepo.getAllUsers().firstWhere(
      (u) => u.phone == phone && u.password == password,
    );
    stdout.writeln('Добро пожаловать, ${user.name}!');
    return user.id;
  } catch (e) {
    stdout.writeln('Неверный телефон или пароль');
    return null;
  }
}

void _register(UserRepository userRepo, RoleRepository roleRepo) {
  stdout.writeln('Регистрация');
  
  int nextId = userRepo.getNextId();
  final id = nextId.toString();
  
  final name = askString('Имя: ', 'Имя');
  final password = askString('Пароль: ', 'Пароль');
  final phone = askString('Телефон: ', 'Телефон');
  
  final userRole = roleRepo.getAllRoles().firstWhere(
    (r) => r.name == 'Пользователь',
    orElse: () => Role(id: '2', name: 'Пользователь'),
  );
  
  final newUser = User(
    id: id,
    name: name,
    password: password,
    phone: phone,
    roleId: userRole.id,
  );
  
  try {
    userRepo.insertUser(newUser);
    stdout.writeln('Регистрация успешна! Ваш ID: $id');
  } catch (e) {
    stdout.writeln('Ошибка: $e');
  }
}

void _listTovars(TovarRepository tovarRepo, CategoryRepository categoryRepo) {
  final tovars = tovarRepo.getAllTovars();
  if (tovars.isEmpty) {
    stdout.writeln('Товаров пока нет.');
    return;
  }
  
  stdout.writeln('Список товаров:');
  for (final t in tovars) {
    final category = categoryRepo.getCategoryById(t.categoryId);
    stdout.writeln('  ID: ${t.id} | ${t.name} | ${t.price} руб | ${category?.name ?? 'без категории'}');
    if (t.description.isNotEmpty) {
      stdout.writeln('      ${t.description}');
    }
  }
}

void _listCategories(CategoryRepository categoryRepo, TovarRepository tovarRepo) {
  final categories = categoryRepo.getAllCategories();
  if (categories.isEmpty) {
    stdout.writeln('Категорий нет.');
    return;
  }
  
  stdout.writeln('Категории:');
  for (final c in categories) {
    final tovarsInCat = tovarRepo.getTovarsByCategory(c.id);
    stdout.writeln('  ${c.id} | ${c.name} (${tovarsInCat.length} товаров)');
  }
}

void _showCart(CartRepository cartRepo, TovarRepository tovarRepo, String userId) {
  while (true) {
    final cart = cartRepo.getCartByUser(userId);
    
    stdout.writeln('\n=== ВАША КОРЗИНА ===');
    
    if (cart.isEmpty) {
      stdout.writeln('Корзина пуста');
    } else {
      double total = 0;
      for (final item in cart) {
        final tovar = tovarRepo.getTovarById(item.tovarId);
        if (tovar != null) {
          final sum = tovar.price * item.kolvo;
          total += sum;
          stdout.writeln('  ID: ${item.id} | ${tovar.name} | ${tovar.price} руб x ${item.kolvo} = ${sum} руб');
        }
      }
      stdout.writeln('ИТОГО: $total руб');
    }
    
    stdout.writeln('Управление корзиной:');
    stdout.writeln('  1 - Добавить товар');
    if (cart.isNotEmpty) {
      stdout.writeln('  2 - Удалить товар');
      stdout.writeln('  3 - Очистить корзину');
    }
    stdout.writeln('  0 - Назад в главное меню');
    stdout.write('Выберите действие: ');
    
    final choice = stdin.readLineSync()?.trim() ?? '';
    switch (choice) {
      case '1':
        _addToCart(cartRepo, tovarRepo, userId);
        break;
      case '2':
        if (cart.isNotEmpty) {
          _removeFromCart(cartRepo, userId);
        } else {
          stdout.writeln('Нет товаров для удаления');
        }
        break;
      case '3':
        if (cart.isNotEmpty) {
          stdout.write('Вы уверены, что хотите очистить корзину? (y/n): ');
          final confirm = stdin.readLineSync()?.trim().toLowerCase();
          if (confirm == 'y') {
            cartRepo.clearCart(userId);
            stdout.writeln('Корзина очищена');
          } else {
            stdout.writeln('Очистка отменена');
          }
        } else {
          stdout.writeln('Корзина и так пуста');
        }
        break;
      case '0':
        return;
      default:
        stdout.writeln('Неизвестная команда.');
    }
  }
}

void _addToCart(CartRepository cartRepo, TovarRepository tovarRepo, String userId) {
  stdout.writeln('ДОБАВЛЕНИЕ ТОВАРА В КОРЗИНУ');
  
  final tovars = tovarRepo.getAllTovars();
  if (tovars.isEmpty) {
    stdout.writeln('Нет доступных товаров. Сначала добавьте товары через меню админа.');
    stdout.write('Нажмите Enter для продолжения...');
    stdin.readLineSync();
    return;
  }
  
  stdout.writeln('Доступные товары:');
  for (final t in tovars) {
    stdout.writeln('  ID: ${t.id} | ${t.name} | ${t.price} руб');
  }
  
  final tovarId = askString('Введите ID товара: ', 'ID товара');
  final tovar = tovarRepo.getTovarById(tovarId);
  
  if (tovar == null) {
    stdout.writeln('Товар с ID $tovarId не найден');
    stdout.write('Нажмите Enter для продолжения...');
    stdin.readLineSync();
    return;
  }
  
  final kolvo = askPositiveInt('Введите количество: ', 'Количество');
  
  int nextId = cartRepo.getNextId();
  final cartId = nextId.toString();
  
  final cartItem = Cart(
    id: cartId,
    userId: userId,
    tovarId: tovarId,
    kolvo: kolvo,
  );
  
  try {
    cartRepo.addToCart(cartItem);
    stdout.writeln('Товар "${tovar.name}" в количестве $kolvo добавлен в корзину!');
  } catch (e) {
    stdout.writeln('Ошибка при добавлении: $e');
  }
  
  stdout.write('Нажмите Enter для продолжения...');
  stdin.readLineSync();
}

void _removeFromCart(CartRepository cartRepo, String userId) {
  stdout.writeln('УДАЛЕНИЕ ТОВАРА ИЗ КОРЗИНЫ');
  
  final cart = cartRepo.getCartByUser(userId);
  if (cart.isEmpty) {
    stdout.writeln('Корзина пуста');
    stdout.write('Нажмите Enter для продолжения...');
    stdin.readLineSync();
    return;
  }
  
  stdout.writeln('Товары в корзине:');
  for (final item in cart) {
    stdout.writeln('  ID позиции: ${item.id}');
  }
  
  final cartId = askString('Введите ID позиции для удаления: ', 'ID позиции');
  
  stdout.write('Вы уверены, что хотите удалить этот товар? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    cartRepo.removeFromCart(cartId);
    stdout.writeln('Товар удален из корзины');
  } else {
    stdout.writeln('Удаление отменено');
  }
  
  stdout.write('Нажмите Enter для продолжения...');
  stdin.readLineSync();
}

void _checkout(CartRepository cartRepo, String userId) {
  final cart = cartRepo.getCartByUser(userId);
  if (cart.isEmpty) {
    stdout.writeln('Корзина пуста. Нечего оформлять.');
    return;
  }
  
  stdout.writeln('   ОФОРМЛЕНИЕ ЗАКАЗА  ');
  double total = 0;
  for (final item in cart) {
    stdout.writeln('  Заказ #${item.id}');
    total++;
  }
  stdout.writeln('Всего позиций: $total');
  stdout.writeln('        ');
  
  stdout.write('Подтверждаете заказ? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    cartRepo.clearCart(userId);
    stdout.writeln('Заказ оформлен! Спасибо за покупку!');
  } else {
    stdout.writeln('Оформление заказа отменено');
  }
}

void _adminTovarMenu(TovarRepository tovarRepo, CategoryRepository categoryRepo) {
  while (true) {
    stdout.writeln('   Управление товарами и категориями (Админ)  ');
    stdout.writeln('  1 - Добавить товар');
    stdout.writeln('  2 - Редактировать товар');
    stdout.writeln('  3 - Удалить товар');
    stdout.writeln('  4 - Список товаров');
    stdout.writeln('  5 - Добавить категорию');
    stdout.writeln('  6 - Редактировать категорию');
    stdout.writeln('  7 - Удалить категорию');
    stdout.writeln('  8 - Список категорий');
    stdout.writeln('  0 - Назад');
    stdout.write('Выберите действие: ');
    
    final choice = stdin.readLineSync()?.trim() ?? '';
    switch (choice) {
      case '1':
        _addTovar(tovarRepo, categoryRepo);
        break;
      case '2':
        _editTovar(tovarRepo, categoryRepo);
        break;
      case '3':
        _deleteTovar(tovarRepo);
        break;
      case '4':
        _listTovars(tovarRepo, categoryRepo);
        break;
      case '5':
        _addCategory(categoryRepo);
        break;
      case '6':
        _editCategory(categoryRepo);
        break;
      case '7':
        _deleteCategory(categoryRepo);
        break;
      case '8':
        _listCategories(categoryRepo, tovarRepo);
        break;
      case '0':
        return;
      default:
        stdout.writeln('Неизвестная команда.');
    }
  }
}

void _addTovar(TovarRepository tovarRepo, CategoryRepository categoryRepo) {
  stdout.writeln('   ДОБАВЛЕНИЕ ТОВАРА  ');
  
  int nextId = tovarRepo.getNextId();
  final id = nextId.toString();
  
  final name = askString('Название товара: ', 'Название');
  final description = askString('Описание (можно пропустить): ', 'Описание');
  final price = askPositiveDouble('Цена: ', 'Цена');
  
  stdout.writeln(' Доступные категории:');
  final categories = categoryRepo.getAllCategories();
  if (categories.isEmpty) {
    stdout.writeln('  Нет категорий. Сначала добавьте категорию.');
    return;
  }
  
  for (final cat in categories) {
    stdout.writeln('  ${cat.id} - ${cat.name}');
  }
  
  final categoryId = askString('ID категории: ', 'ID категории');
  
  if (categoryRepo.getCategoryById(categoryId) == null) {
    stdout.writeln('Категория с ID $categoryId не найдена');
    return;
  }
  
  final tovar = Tovar(
    id: id,
    name: name,
    description: description.isEmpty ? '' : description,
    price: price,
    categoryId: categoryId,
  );
  
  tovarRepo.insertTovar(tovar);
  stdout.writeln('Товар добавлен! ID: $id');
}

void _editTovar(TovarRepository tovarRepo, CategoryRepository categoryRepo) {
  stdout.writeln('   РЕДАКТИРОВАНИЕ ТОВАРА  ');
  _listTovars(tovarRepo, categoryRepo);
  
  final id = askString('ID товара для редактирования: ', 'ID');
  final tovar = tovarRepo.getTovarById(id);
  
  if (tovar == null) {
    stdout.writeln('Товар не найден');
    return;
  }
  
  final newName = askString('Новое название (${tovar.name}): ', 'Название');
  final newDesc = askString('Новое описание (${tovar.description}): ', 'Описание');
  final newPrice = askPositiveDouble('Новая цена (${tovar.price}): ', 'Цена');
  
  final updatedTovar = Tovar(
    id: tovar.id,
    name: newName.isEmpty ? tovar.name : newName,
    description: newDesc.isEmpty ? tovar.description : newDesc,
    price: newPrice,
    categoryId: tovar.categoryId,
  );
  
  tovarRepo.updateTovar(updatedTovar);
  stdout.writeln('Товар обновлен!');
}

void _deleteTovar(TovarRepository tovarRepo) {
  stdout.writeln('   УДАЛЕНИЕ ТОВАРА  ');
  final id = askString('ID товара для удаления: ', 'ID');
  
  stdout.write('Вы уверены, что хотите удалить товар? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    tovarRepo.deleteTovar(id);
    stdout.writeln('Товар удален!');
  } else {
    stdout.writeln('Удаление отменено');
  }
}

void _addCategory(CategoryRepository categoryRepo) {
  stdout.writeln('   ДОБАВЛЕНИЕ КАТЕГОРИИ  ');
  
  int nextId = categoryRepo.getNextId();
  final id = nextId.toString();
  final name = askString('Название категории: ', 'Название');
  
  final category = Category(id: id, name: name);
  categoryRepo.insertCategory(category);
  stdout.writeln('Категория добавлена! ID: $id');
}

void _editCategory(CategoryRepository categoryRepo) {
  stdout.writeln('   РЕДАКТИРОВАНИЕ КАТЕГОРИИ  ');
  
  final categories = categoryRepo.getAllCategories();
  if (categories.isEmpty) {
    stdout.writeln('Нет категорий для редактирования');
    return;
  }
  
  stdout.writeln('Доступные категории:');
  for (final cat in categories) {
    stdout.writeln('  ${cat.id} - ${cat.name}');
  }
  
  final id = askString('ID категории для редактирования: ', 'ID');
  final category = categoryRepo.getCategoryById(id);
  
  if (category == null) {
    stdout.writeln('Категория не найдена');
    return;
  }
  
  final newName = askString('Новое название (${category.name}): ', 'Название');
  
  final updatedCategory = Category(
    id: category.id,
    name: newName.isEmpty ? category.name : newName,
  );
  
  categoryRepo.updateCategory(updatedCategory);
  stdout.writeln('Категория обновлена!');
}

void _deleteCategory(CategoryRepository categoryRepo) {
  stdout.writeln('   УДАЛЕНИЕ КАТЕГОРИИ  ');
  
  final categories = categoryRepo.getAllCategories();
  if (categories.isEmpty) {
    stdout.writeln('Нет категорий для удаления');
    return;
  }
  
  stdout.writeln('Доступные категории:');
  for (final cat in categories) {
    stdout.writeln('  ${cat.id} - ${cat.name}');
  }
  
  final id = askString('ID категории для удаления: ', 'ID');
  
  stdout.writeln('ВНИМАНИЕ: Удаление категории удалит все товары в ней!');
  stdout.write('Вы уверены? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    categoryRepo.deleteCategory(id);
    stdout.writeln('Категория удалена!');
  } else {
    stdout.writeln('Удаление отменено');
  }
}

void _adminUserMenu(UserRepository userRepo, RoleRepository roleRepo) {
  while (true) {
    stdout.writeln('   Управление пользователями и ролями (Админ)  ');
    stdout.writeln('  1 - Список пользователей');
    stdout.writeln('  2 - Удалить пользователя');
    stdout.writeln('  3 - Назначить роль');
    stdout.writeln('  4 - Список ролей');
    stdout.writeln('  5 - Добавить роль');
    stdout.writeln('  6 - Редактировать роль');
    stdout.writeln('  7 - Удалить роль');
    stdout.writeln('  0 - Назад');
    stdout.write('Выберите действие: ');
    
    final choice = stdin.readLineSync()?.trim() ?? '';
    switch (choice) {
      case '1':
        _listUsers(userRepo, roleRepo);
        break;
      case '2':
        _deleteUser(userRepo);
        break;
      case '3':
        _assignRole(userRepo, roleRepo);
        break;
      case '4':
        _listRoles(roleRepo);
        break;
      case '5':
        _addRole(roleRepo);
        break;
      case '6':
        _editRole(roleRepo);
        break;
      case '7':
        _deleteRole(roleRepo, userRepo);
        break;
      case '0':
        return;
      default:
        stdout.writeln('Неизвестная команда.');
    }
  }
}

void _listUsers(UserRepository userRepo, RoleRepository roleRepo) {
  final users = userRepo.getAllUsers();
  if (users.isEmpty) {
    stdout.writeln('Пользователей нет.');
    return;
  }
  
  stdout.writeln(' Список пользователей:');
  for (final u in users) {
    final role = roleRepo.getRoleById(u.roleId);
    stdout.writeln('  ID: ${u.id} | ${u.name} | ${u.phone} | роль: ${role?.name ?? 'неизвестно'}');
  }
}

void _deleteUser(UserRepository userRepo) {
  stdout.writeln('   УДАЛЕНИЕ ПОЛЬЗОВАТЕЛЯ  ');
  final id = askString('ID пользователя для удаления: ', 'ID');
  
  stdout.write('Вы уверены, что хотите удалить пользователя? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    userRepo.deleteUser(id);
    stdout.writeln('Пользователь удален!');
  } else {
    stdout.writeln('Удаление отменено');
  }
}

void _assignRole(UserRepository userRepo, RoleRepository roleRepo) {
  stdout.writeln('   НАЗНАЧЕНИЕ РОЛИ  ');
  
  final userId = askString('ID пользователя: ', 'ID');
  final user = userRepo.getUserById(userId);
  
  if (user == null) {
    stdout.writeln('Пользователь не найден');
    return;
  }
  
  stdout.writeln(' Доступные роли:');
  for (final role in roleRepo.getAllRoles()) {
    stdout.writeln('  ${role.id} - ${role.name}');
  }
  
  final roleId = askString('ID роли: ', 'ID роли');
  
  if (roleRepo.getRoleById(roleId) == null) {
    stdout.writeln('Роль с ID $roleId не найдена');
    return;
  }
  
  final updatedUser = User(
    id: user.id,
    name: user.name,
    password: user.password,
    phone: user.phone,
    roleId: roleId,
  );
  
  userRepo.updateUser(updatedUser);
  stdout.writeln('Роль назначена!');
}

void _listRoles(RoleRepository roleRepo) {
  final roles = roleRepo.getAllRoles();
  if (roles.isEmpty) {
    stdout.writeln('Ролей нет.');
    return;
  }
  
  stdout.writeln(' Список ролей:');
  for (final role in roles) {
    stdout.writeln('  ${role.id} - ${role.name}');
  }
}

void _addRole(RoleRepository roleRepo) {
  stdout.writeln('   ДОБАВЛЕНИЕ РОЛИ  ');
  
  int nextId = roleRepo.getNextId();
  final id = nextId.toString();
  final name = askString('Название роли: ', 'Название');
  
  final role = Role(id: id, name: name);
  roleRepo.insertRole(role);
  stdout.writeln('Роль добавлена! ID: $id');
}

void _editRole(RoleRepository roleRepo) {
  stdout.writeln('   РЕДАКТИРОВАНИЕ РОЛИ  ');
  
  final roles = roleRepo.getAllRoles();
  if (roles.isEmpty) {
    stdout.writeln('Нет ролей для редактирования');
    return;
  }
  
  stdout.writeln('Доступные роли:');
  for (final role in roles) {
    stdout.writeln('  ${role.id} - ${role.name}');
  }
  
  final id = askString('ID роли для редактирования: ', 'ID');
  final role = roleRepo.getRoleById(id);
  
  if (role == null) {
    stdout.writeln('Роль не найдена');
    return;
  }
  
  final newName = askString('Новое название (${role.name}): ', 'Название');
  
  final updatedRole = Role(
    id: role.id,
    name: newName.isEmpty ? role.name : newName,
  );
  
  roleRepo.updateRole(updatedRole);
  stdout.writeln('Роль обновлена!');
}

void _deleteRole(RoleRepository roleRepo, UserRepository userRepo) {
  stdout.writeln('   УДАЛЕНИЕ РОЛИ  ');
  
  final roles = roleRepo.getAllRoles();
  if (roles.isEmpty) {
    stdout.writeln('Нет ролей для удаления');
    return;
  }
  
  stdout.writeln('Доступные роли:');
  for (final role in roles) {
    if (role.id == '1' || role.id == '2') {
      stdout.writeln('  ${role.id} - ${role.name} (СИСТЕМНАЯ - НЕЛЬЗЯ УДАЛИТЬ)');
    } else {
      stdout.writeln('  ${role.id} - ${role.name}');
    }
  }
  
  final id = askString('ID роли для удаления: ', 'ID');
  
  if (id == '1' || id == '2') {
    stdout.writeln('Нельзя удалить системную роль!');
    return;
  }
  
  final users = userRepo.getAllUsers();
  final usersWithRole = users.where((u) => u.roleId == id);
  
  if (usersWithRole.isNotEmpty) {
    stdout.writeln('Невозможно удалить: у ${usersWithRole.length} пользователей эта роль');
    stdout.writeln('Сначала измените роль у этих пользователей:');
    for (final user in usersWithRole) {
      stdout.writeln('  - ${user.name} (${user.phone})');
    }
    return;
  }
  
  stdout.write('Вы уверены, что хотите удалить роль? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirm == 'y') {
    try {
      roleRepo.deleteRole(id);
      stdout.writeln('Роль удалена!');
    } catch (e) {
      stdout.writeln('Ошибка: $e');
    }
  } else {
    stdout.writeln('Удаление отменено');
  }
}

void _showAllFromDb(
  TovarRepository tovarRepo,
  CategoryRepository categoryRepo,
  UserRepository userRepo,
  RoleRepository roleRepo,
  CartRepository cartRepo,
) {
  stdout.writeln('ПОЛНОЕ СОДЕРЖАНИЕ БАЗЫ ДАННЫХ');
  
  stdout.writeln(' РОЛИ:');
  final roles = roleRepo.getAllRoles();
  if (roles.isEmpty) {
    stdout.writeln('  (нет данных)');
  } else {
    for (final role in roles) {
      stdout.writeln('  ${role.id} - ${role.name}');
    }
  }
  
  stdout.writeln(' КАТЕГОРИИ:');
  final categories = categoryRepo.getAllCategories();
  if (categories.isEmpty) {
    stdout.writeln('  (нет данных)');
  } else {
    for (final cat in categories) {
      final tovarsCount = tovarRepo.getTovarsByCategory(cat.id).length;
      stdout.writeln('  ${cat.id} - ${cat.name} (${tovarsCount} товаров)');
    }
  }
  
  stdout.writeln(' ПОЛЬЗОВАТЕЛИ:');
  final users = userRepo.getAllUsers();
  if (users.isEmpty) {
    stdout.writeln('  (нет данных)');
  } else {
    for (final user in users) {
      final role = roleRepo.getRoleById(user.roleId);
      stdout.writeln('  ${user.id} - ${user.name} (${user.phone}) - роль: ${role?.name ?? '?'}');
    }
  }
  
  stdout.writeln(' ТОВАРЫ:');
  final tovars = tovarRepo.getAllTovars();
  if (tovars.isEmpty) {
    stdout.writeln('  (нет данных)');
  } else {
    for (final tovar in tovars) {
      final category = categoryRepo.getCategoryById(tovar.categoryId);
      stdout.writeln('  ${tovar.id} - ${tovar.name} | ${tovar.price} руб | ${category?.name ?? 'без категории'}');
      if (tovar.description.isNotEmpty) {
        stdout.writeln('      Описание: ${tovar.description}');
      }
    }
  }
  
  stdout.writeln(' КОРЗИНА:');
  bool hasCartItems = false;
  for (final user in users) {
    final cartItems = cartRepo.getCartByUser(user.id);
    if (cartItems.isNotEmpty) {
      hasCartItems = true;
      stdout.writeln('  Пользователь: ${user.name}:');
      double userTotal = 0;
      for (final item in cartItems) {
        final tovar = tovarRepo.getTovarById(item.tovarId);
        if (tovar != null) {
          final sum = tovar.price * item.kolvo;
          userTotal += sum;
          stdout.writeln('      - ${tovar.name} x${item.kolvo} = ${sum} руб');
        }
      }
      stdout.writeln('      Итого: $userTotal руб');
    }
  }
  if (!hasCartItems) {
    stdout.writeln('  (пусто)');
  }
  
}