import 'package:pizzatower/src/domain/models/id.dart';
class User implements IdentityV{
  @override
  final String id;
  final String name;
  final String password;
  final String phone;
  final String roleId;

  const User({required this.id, required this.name, required this.password, required this.phone, required this.roleId});

  Map<String, dynamic> toMap()=>{
    'id':id,
    'name':name, 
    'password':password,
    'phone':phone,
    'roleId':roleId
  };

  factory User.fromMap(Map<String, dynamic> map) {
  return User(
    id: (map['id'] as int).toString(),
    name: map['name'] as String,
    password: map['password'] as String,
    phone: map['phone'] as String,
    roleId: (map['roleId'] as int).toString(),
  );
  }
  @override 
  String toString()=> "$name ($password) $phone роль $roleId";
}