import '../../domain/models/cart.dart';
import '../database.dart';

class CartRepository {
  final PizzaDatabase _db;

  CartRepository(this._db);

  int getNextId() {
    final result = _db.db.select('SELECT MAX(id) as max_id FROM cart');
    final maxId = result.first['max_id'] as int? ?? 0;
    return maxId + 1;
  }

  void addToCart(Cart cartItem) {
    _db.db.execute(
      'INSERT OR REPLACE INTO cart (id, userId, tovarId, kolvo) VALUES (?, ?, ?, ?)',
      [int.parse(cartItem.id), int.parse(cartItem.userId), int.parse(cartItem.tovarId), cartItem.kolvo],
    );
  }

  List<Cart> getCartByUser(String userId) {
    final rows = _db.db.select(
      'SELECT * FROM cart WHERE userId = ? ORDER BY id',
      [int.parse(userId)],
    );
    return rows.map((row) => Cart.fromMap(row)).toList();
  }

  void updateQuantity(String cartId, int newKolvo) {
    _db.db.execute(
      'UPDATE cart SET kolvo = ? WHERE id = ?',
      [newKolvo, int.parse(cartId)],
    );
  }

  void removeFromCart(String cartId) {
    _db.db.execute('DELETE FROM cart WHERE id = ?', [int.parse(cartId)]);
  }

  void clearCart(String userId) {
    _db.db.execute('DELETE FROM cart WHERE userId = ?', [int.parse(userId)]);
  }
}