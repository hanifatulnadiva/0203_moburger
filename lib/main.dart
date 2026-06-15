import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/report/report_bloc.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/data/repositories/menu_repository.dart';
import 'package:moburger/data/repositories/order_repository.dart';
import 'package:moburger/data/repositories/topping_repository.dart';
import 'package:moburger/data/repositories/user_repository.dart';
import 'package:moburger/data/repositories/report_repository.dart';
import 'package:moburger/ui/Onboarding/page.dart';
import 'package:moburger/ui/report/laporan_penjualan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://donretxkjjnitxjuyruh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvbnJldHhrampuaXR4anV5cnVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MTExNTYsImV4cCI6MjA5Mjk4NzE1Nn0.0Y-b9GGGAyHLDYXnj5C4Is3EaiigFZTGtr-yctZWyTc',
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
          create: (context) => AuthBloc(repository: AuthRepository()),
        ),
        BlocProvider(create: (context) => MenuBloc(repository: MenuRepository())),
        BlocProvider(create: (context) => ToppingBloc(repository: ToppingRepository())),
        BlocProvider(create: (context) => OrderBloc(orderRepository: OrderRepository())),
        BlocProvider<CartBloc>(create: (context) => CartBloc()),
        BlocProvider(create: (context) => ReportBloc(ReportRepository()),
        child: ReportScreen(),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(), 
      ),
    );
  }
}