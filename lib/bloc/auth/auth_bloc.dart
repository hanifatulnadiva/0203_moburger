import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/data/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'dart:developer'as developer;

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  final AuthRepository repository;
  AuthBloc({required this.repository}): super(AuthInitial()){
    on<AppStarted>((event, emit) async {
      developer.log('Checking current session...', name: 'AuthBloc');
      try {
        final user = await repository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user)); 
          developer.log('Session found. User: ${user.email}, Role: ${user.role}', name: 'AuthBloc');
        } else {
          emit(Unauthenticated());
          developer.log('No active session found.', name: 'AuthBloc');
        }
      } catch (e) {
        emit(Unauthenticated());
        developer.log('Error checking session: $e', name: 'AuthBloc');
      }
    });

    on<LoginRequested>((event,emit)async{
      emit(AuthLoading());
      developer.log('Attempting login for:${event.email}', name:'AuthBloc');
      try{
        final user=await repository.login(event.email, event.password);
        emit(Authenticated(user));
        developer.log('Status:Authenticated (welcome ${user.nama_lengkap})', name:'AuthBloc');
      }
      catch(e){
        emit(AuthError(e.toString()));
        developer.log('Status:AuthError-$e', name:'AuthBloc');
      }
    });

    on<GoogleLoginRequested>((event,emit)async{
      emit(AuthLoading());
      developer.log('Attempting Google Sign -In', name :'AuthBloc');
      try{
        await repository.signInWithGoogle();
      }catch(e){
        emit(AuthError(e.toString()));
        developer.log('Google Sign-In Error:$e', name:'AuthBloc');
      }
    });

    on<RegisterRequested>((event,emit)async{
      emit(AuthLoading());
      try{
        await repository.register(
          email: event.email,
          password: event.password,
          nama_lengkap: event.nama_lengkap,
          nohp: event.nohp, 
        );
        emit(Unauthenticated());
        developer.log('Register sukses', name:'AuthBloc');
      }catch(e){
        emit(AuthError(e.toString()));
        developer.log('Register Error:$e', name:'AuthBloc');
      }
    });

    // Di AuthBloc
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Supabase.instance.client.auth.signOut();
        emit(Unauthenticated()); 
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}