import 'package:pizzatower/src/domain/models/id.dart';
class Cart implements IdentityV{
  @override
  final String id;
  final String userId;
  final String tovarId;
  final int kolvo;

  const Cart({required this.id, required this.userId, required this.tovarId, required this.kolvo});

  Map<String, dynamic> toMap()=>{
    'id':id,
    'name':userId, 
    'description':tovarId,
    'price':kolvo
  };

  factory Cart.fromMap(Map<String, dynamic> map) {
  return Cart(
    id: (map['id'] as int).toString(),
    userId: (map['userId'] as int).toString(),
    tovarId: (map['tovarId'] as int).toString(),
    kolvo: _asInt(map['kolvo']),
  );
  }

  static int _asInt(Object? v){
    if (v is int) return v.toInt();
    if (v is num) return v.toInt();
    throw FormatException("Ожидали число", v);

  }

  @override 
  String toString()=> " Владелец $userId Товар $tovarId : $kolvo";
}