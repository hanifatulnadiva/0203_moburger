import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
import 'package:moburger/ui/dashboard/customer_home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  await Supabase.initialize(
    url: 'https://donretxkjjnitxjuyruh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvbnJldHhrampuaXR4anV5cnVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MTExNTYsImV4cCI6MjA5Mjk4NzE1Nn0.0Y-b9GGGAyHLDYXnj5C4Is3EaiigFZTGtr-yctZWyTc',
  );

  final directory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );

  final storage = const FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  String? role = await storage.read(key: 'user_role');

  if (token != null) {
    await Supabase.instance.client.auth.recoverSession(token);
  }
  runApp(MyApp(isLoggedIn: token != null, userRole: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userRole;
  const MyApp({super.key, required this.isLoggedIn, this.userRole});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(repository: AuthRepository())),
        BlocProvider(create: (context) => MenuBloc(repository: MenuRepository())),
        BlocProvider(create: (context) => ToppingBloc(repository: ToppingRepository())),
        BlocProvider(create: (context) => OrderBloc(orderRepository: OrderRepository())),
        BlocProvider<CartBloc>(create: (context) => CartBloc()),
        BlocProvider(create: (context) => ReportBloc(ReportRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn 
            ? CustomerDashboardScreen(userRole: userRole ?? 'user') 
            : const OnboardingScreen(),
      ),
    );
  }
}