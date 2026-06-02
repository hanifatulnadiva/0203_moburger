import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:moburger/ui/auth/register_page.dart';

// TODO: Import halaman dashboard kamu di sini
// import 'package:moburger/presentation/home/customer_home_screen.dart';
// import 'package:moburger/presentation/admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  bool _isValidEmail(String email){
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang kembali, ${state.user.nama_lengkap}!'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // PERCABANGAN HALAMAN BERDASARKAN ROLE USER
            if (state.user.role == 'admin') {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              // );
            } else {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
              // );
            }
          }
          
          if (state is AuthError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  'Login Gagal', 
                  style: TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold),
                ),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK', style: TextStyle(color: AppColors.orange)),
                  ),
                ],
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '🍔',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MoBurger',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.darkRed,
                    ),
                  ),
                  const Text(
                    'Silakan masuk untuk menikmati burger terbaik',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Masukkan email Anda',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email tidak boleh kosong';
                      if(!_isValidEmail(val))
                        return 'format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Masukkan password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password tidak boleh kosong';
                      if (val.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. TOMBOL MASUK MANUAL
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'Masuk',
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginRequested(
                                _emailController.text.trim(), 
                                _passwordController.text,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppColors.textSecondary, thickness: 0.5)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('atau', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      Expanded(child: Divider(color: AppColors.textSecondary, thickness: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.textSecondary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 32, color: AppColors.orange),
                      label: const Text(
                        'Masuk dengan Google', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(GoogleLoginRequested());
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: AppColors.orange, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}