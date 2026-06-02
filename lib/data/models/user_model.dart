import 'package:equatable/equatable.dart';

class UserModel extends Equatable{
  final String id;
  final String nama_lengkap;
  final String email;
  final String nohp;
  final String role;

  const UserModel({
    required this.id,
    required this.nama_lengkap,
    required this.email,
    required this.nohp,
    required this.role
    
  });
  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
      id: json['id'] ?? '',
      nama_lengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      nohp: json['nohp'] ?? '',
      role: json['role'] ?? '',

    );
  }
  @override
  List<Object?> get props=>[id,nama_lengkap, email, nohp, role];
}