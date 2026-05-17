import 'package:pizzatower/src/domain/models/id.dart';

class Tovar implements IdentityV {
  @override
  final String id;
  final String name;
  final String description;
  final double price;  // Изменено с int на double
  final String categoryId;

  const Tovar({
    required this.id, 
    required this.name, 
    required this.description, 
    required this.price, 
    required this.categoryId
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name, 
    'description': description,
    'price': price,
    'categoryId': categoryId
  };

  factory Tovar.fromMap(Map<String, dynamic> map) {
  return Tovar(
    id: (map['id'] as int).toString(),
    name: map['name'] as String,
    description: map['description'] as String,
    price: _asDouble(map['price']),
    categoryId: (map['categoryId'] as int).toString(),
  );
}

  static double _asDouble(Object? v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    throw FormatException("Ожидали число", v);
  }

  @override 
  String toString() => "$name | $description | $price руб | категория $categoryId";
}