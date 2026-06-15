import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/loading_widget.dart';
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, 
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoadingWidget.showLoadingDialog(context);
          }
          if (state is Authenticated) {
            AppLoadingWidget.hideLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang kembali, ${state.user.nama_lengkap}!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CustomerDashboardScreen(userRole: state.user.role),
              ),
            );
          }
          if (state is AuthError) {
            AppLoadingWidget.hideLoadingDialog(context);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("Error"),
                content: Text("Email atau password salah"),
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
                    height: screenHeight * 0.50,
                    width: MediaQuery.of(context).size.width + 2.0, 
                    color: AppColors.darkRed,
                    child: SafeArea(
                      bottom: false, 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 100,
                            child: Image.asset(
                              'assets/logo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Welcome Back!!!',
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
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width + 2.0,
                    color: AppColors.background,
                  ),
                ),
              ],
            ),
            Positioned.fill(
              top: (screenHeight * 0.30) - 30,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24.0, 
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black45,
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
                              style: AppTextStyles.headingBold
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Silakan masuk untuk menikmati burger terbaik',
                              textAlign: TextAlign.left,
                              style: AppTextStyles.bodyRegular
                            ),
                            const SizedBox(height: 28),

                            const Text('Email',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Masukkan email Anda',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!_isValidEmail(val)) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text('Password',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              //autovalidateMode: AutovalidateMode.onUserInteraction,
                              hintText: 'Masukkan password',
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
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (val.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
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
                                Padding( padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('atau',
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
                                icon: const Icon(Icons.g_mobiledata,
                                  size: 32,
                                  color: AppColors.orange,
                                ),
                                label: const Text('Masuk dengan Google',
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
                                const Text('Belum punya akun? ',style: AppTextStyles.bodyRegular),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Daftar Sekarang',style: AppTextStyles.bodyOrange),
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