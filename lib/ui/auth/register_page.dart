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
        child: Stack(
          children: [
            Column(
              children: [
                ClipPath(
                  clipper: CurveClipper(),
                  child: Container(
                    height:screenHeight *0.50,
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
                          const Text('Create New Account',
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Card(
                  color: AppColors.white,
                  elevation: 5,
                  shadowColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Register',
                            textAlign: TextAlign.left,
                            style: AppTextStyles.headingBold
                          ),
                          const SizedBox(height: 4),
                          const Text('Lengkapi data diri Anda untuk mulai memesan',
                            textAlign: TextAlign.left,
                            style: AppTextStyles.bodyRegular
                          ),
                          const SizedBox(height: 24),
                          
                          const Text('Nama Lengkap',style: AppTextStyles.formLabel),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icons.person_outline,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Nama tidak boleh kosong';
                              final regex = RegExp(r"^[a-zA-Z\s'-]+$");
                              if (!regex.hasMatch(val)) {
                                return 'Nama hanya boleh huruf, spasi, tanda (-) atau (\')';
                              }
                              if (val.trim().length < 2) {
                                return 'Nama terlalu pendek';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text('Nomor Telepon',
                            style: AppTextStyles.formLabel
                          ),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: 'Nomor HP (WhatsApp)',
                            prefixIcon: Icons.phone_android_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Nomor HP tidak boleh kosong';
                              if (val.length < 10) return 'Nomor HP minimal 10 digit';
                              String phone = val.replaceAll(' ', '');
                              final regex = RegExp(r'^(\\+62|62|0)8[1-9][0-9]{7,11}$');

                              if (!regex.hasMatch(phone)) {
                                return 'Format nomor HP tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text('Email',
                            style: AppTextStyles.formLabel
                          ),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Alamat Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Email tidak boleh kosong';
                              if (!_isValidEmail(val)) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text('Password',
                            style: AppTextStyles.formLabel
                          ),
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
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: AppTextStyles.bodyRegular,
                              ),
                              GestureDetector(
                                onTap: (){
                                  _nameController.clear();
                                  _phoneController.clear();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _formKey.currentState?.reset();
                                  Navigator.pop(context);
                                } ,
                                child: const Text('Masuk Disini',style: AppTextStyles.bodyOrange)
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

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}