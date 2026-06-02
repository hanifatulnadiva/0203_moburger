import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  bool _isValidEmail (String email){
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Berhasil! Silakan masuk dengan akun Anda.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
                    'Gabung Bersama Kami ✨',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.darkRed
                    ),
                  ),
                  const Text(
                    'Lengkapi data diri Anda untuk mulai memesan',
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Nama tidak boleh kosong';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    controller: _phoneController,
                    hintText: 'Nomor HP (WhatsApp)',
                    prefixIcon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Nomor HP tidak boleh kosong';
                      if (val.length < 10) return 'Nomor HP minimal 10 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Alamat Email',
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
                    hintText: 'Kata Sandi (Password)',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password tidak boleh kosong';
                      if (val.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
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
                                _emailController.text.trim(),
                                _passwordController.text,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Masuk Di Sini',
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