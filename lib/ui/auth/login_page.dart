import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:moburger/ui/auth/register_page.dart';
import 'package:moburger/ui/dashboard/customer_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Selamat datang kembali, ${state.user.nama_lengkap}!',
                ),
                backgroundColor: AppColors.success,
              ),
            );

            if (state.user.role == 'admin') {
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
            } else {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const CustomerDashboardScreen())
              );
            }
          }

          if (state is AuthError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  'Login Gagal',
                  style: TextStyle(
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: AppColors.orange),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                ClipPath(
                  clipper: CurveClipper(),
                  child: Container(
                    height: screenHeight *0.50,
                    color: AppColors.darkRed,
                    width: double.infinity,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 100,
                            child: Image.asset(
                              'assets/logo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Welcome Back!!!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container(color: AppColors.background)),
              ],
            ),

            Positioned.fill(
              top: (screenHeight * 0.30) - 50,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 28.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Silakan masuk untuk menikmati burger terbaik',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Masukkan email Anda',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Email tidak boleh kosong';
                              if (!_isValidEmail(val))
                                return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Password tidak boleh kosong';
                              if (val.length < 6)
                                return 'Password minimal 6 karakter';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.darkRed,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              errorStyle: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.textSecondary,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.orange,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

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
                          const SizedBox(height: 20),

                          Row(
                            children: const [
                              Expanded(
                                child: Divider(
                                  color: AppColors.textSecondary,
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'atau',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.textSecondary,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.textSecondary,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.g_mobiledata,
                                size: 32,
                                color: AppColors.orange,
                              ),
                              label: const Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  GoogleLoginRequested(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    var controlPoint = Offset(size.width / 2, size.height + 15);
    var endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
