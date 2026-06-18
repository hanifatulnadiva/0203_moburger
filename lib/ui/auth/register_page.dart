import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
          // Sesuaikan 'Authenticated' dengan state sukses di AuthBloc Anda
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context); // Kembali ke Login
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
                    color: AppColors.darkRed,
                    width: double.infinity,
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 100,
                            child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                          const Text('Create New Account',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Card(
                  color: AppColors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Register', style: AppTextStyles.headingBold),
                          const SizedBox(height: 4),
                          const Text('Lengkapi data diri Anda untuk mulai memesan', style: AppTextStyles.bodyRegular),
                          const SizedBox(height: 24),
                          
                          // Input Fields
                          const Text('Nama Lengkap',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icons.person_outline,
                            validator: (val) => (val == null || val.trim().length < 2) ? 'Nama tidak valid' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Nomor HP',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: 'Nomor HP',
                            prefixIcon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (val) => (val == null || val.length < 10) ? 'Nomor HP tidak valid' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Email',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Alamat Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => !_isValidEmail(val ?? '') ? 'Email tidak valid' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Password',style:AppTextStyles.formLabel),
                            const SizedBox(height: 6),
                          CustomTextField(
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            hintText: 'Masukkan password',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (val) => (val == null || val.length < 6) ? 'Password minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 24),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return PrimaryButton(
                                text: 'Daftar Sekarang',
                                isLoading: state is AuthLoading,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      RegisterRequested(
                                        _nameController.text.trim(),
                                        _phoneController.text.trim(),
                                        _emailController.text.trim().toLowerCase(),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sudah punya akun? ', style: AppTextStyles.bodyRegular),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text('Masuk Disini', style: AppTextStyles.bodyOrange),
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
    path.quadraticBezierTo(size.width / 2, size.height + 15, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}