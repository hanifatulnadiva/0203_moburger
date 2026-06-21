import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object>get props =>[];
}
class AppStarted extends AuthEvent{}
class LoginRequested extends AuthEvent{
  final String email, password;
  LoginRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}
class GoogleLoginRequested extends AuthEvent{}
class RegisterRequested extends AuthEvent{
  final String nama_lengkap, nohp, email, password;
  RegisterRequested(this.nama_lengkap, this.nohp, this.email, this.password);
  @override
  List<Object> get props => [nama_lengkap, nohp,email,password];
}
class LogoutRequested extends AuthEvent{}

class UpdateProfileRequested extends AuthEvent {
  final String id,namaLengkap, nohp;

  UpdateProfileRequested({
    required this.id,
    required this.namaLengkap,
    required this.nohp,
  });
  @override
  List<Object> get props => [id, namaLengkap, nohp];
}

class ChangePasswordRequested extends AuthEvent {
  final String newPassword;

  ChangePasswordRequested(this.newPassword);
  @override
  List<Object> get props => [newPassword];
}