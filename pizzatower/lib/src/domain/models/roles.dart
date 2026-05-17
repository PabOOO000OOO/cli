import 'package:pizzatower/src/domain/models/id.dart';
class Role implements IdentityV{
  @override
  final String id;
  final String name;

  const Role({required this.id, required this.name});

  Map<String, dynamic> toMap()=>{
    'id':id,
    'name':name
  };

  factory Role.fromMap(Map<String, dynamic> map) {
  return Role(
    id: (map['id'] as int).toString(),
    name: map['name'] as String,
  );
  }
  @override 
  String toString()=> "   $name ";
}