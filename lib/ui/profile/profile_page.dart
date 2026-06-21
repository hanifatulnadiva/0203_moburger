import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/app_contants.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_alert_dialog.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:moburger/data/models/user_model.dart';
import 'package:moburger/ui/auth/login_page.dart';
import 'package:moburger/ui/profile/about_page.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nama_lengkap);
    _phoneController = TextEditingController(text: widget.user.nohp);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await CustomAlertDialog.showDeleteDialog(
      context: context,
      title: "Konfirmasi Keluar",
      content: "Apakah Anda yakin ingin keluar dari akun ini?",
      isDelete: false,
    );

    if (shouldLogout == true && mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }

  void _showEditDialog() { 
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text("Edit Profile"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: "Nama Lengkap",
                prefixIcon: Icons.person,
                validator: (val) => (val == null || val.isEmpty) ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _phoneController,
                hintText: "No HP",
                prefixIcon: Icons.phone,
                validator: (val) => (val == null || val.length < 10) ? "No HP tidak valid" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(UpdateProfileRequested(
                      id: widget.user.id,
                      namaLengkap: _nameController.text,
                      nohp: _phoneController.text,
                    ));
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showChangePassword() {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: passwordController,
                hintText: "Password baru",
                prefixIcon: Icons.lock,
                obscureText: true,
                validator: (val) {
                  if (val == null || val.length < AppConstants.minPasswordLength) {
                    return "Minimal ${AppConstants.minPasswordLength} karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: confirmPasswordController,
                hintText: "Konfirmasi password baru",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (val) {
                  if (val != passwordController.text) {
                    return "Password tidak cocok";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(ChangePasswordRequested(passwordController.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.orange),
      title: Text(title, style: TextStyle(color: isLogout ? AppColors.error : AppColors.textPrimary, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentUser = (state is Authenticated) ? state.user : widget.user;

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.darkRed,
            appBar: AppBar(
              title: const Text("Profil", style: TextStyle(color: AppColors.white)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.white),
            ),
            body: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.yellow,
                  child: Icon(Icons.person, size: 60, color: AppColors.darkRed),
                ),
                const SizedBox(height: 15),
                Text(currentUser.nama_lengkap, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(currentUser.email, style: const TextStyle(color: AppColors.white)),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildMenuItem(Icons.info_outline, "Tentang Moburger", () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const AboutScreen()),
                          );
                        }),
                        _buildMenuItem(Icons.person_outline, "Detail User", _showEditDialog),
                        _buildMenuItem(Icons.lock_outline, "Ganti Password", _showChangePassword),
                        const Divider(color: AppColors.textSecondary),
                        _buildMenuItem(Icons.logout, "Keluar", _handleLogout, isLogout: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}