import 'package:pizzatower/src/domain/models/id.dart';
class Category implements IdentityV{
  @override
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  Map<String, dynamic> toMap()=>{
    'id':id,
    'name':name
  };

  factory Category.fromMap(Map<String, dynamic> map) {
  return Category(
    id: (map['id'] as int).toString(),
    name: map['name'] as String,
  );
  }
  @override 
  String toString()=> "   $name ";
}