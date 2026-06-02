import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/data/repositories/user_repository.dart';
import 'package:moburger/ui/Onboarding/page.dart';
import 'package:moburger/ui/auth/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://donretxkjjnitxjuyruh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvbnJldHhrampuaXR4anV5cnVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MTExNTYsImV4cCI6MjA5Mjk4NzE1Nn0.0Y-b9GGGAyHLDYXnj5C4Is3EaiigFZTGtr-yctZWyTc', // Ganti dengan Anon Key kamu
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            repository: AuthRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(),
      ),
    );
  }
}