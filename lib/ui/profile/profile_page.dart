import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_event.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_alert_dialog.dart';// Import custom text field Anda
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:moburger/data/models/user_model.dart';
import 'package:moburger/ui/auth/login_page.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nama_lengkap);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi Logout via AuthBloc
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

  // Dialog Edit Profil menggunakan CustomTextField
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Profil", style: TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold)),
        content: CustomTextField(
          controller: _nameController,
          hintText: "Masukkan nama lengkap",
          prefixIcon: Icons.person_outline,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              // Logika update ke repository bisa ditambahkan di sini
              setState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Tampilkan indikator loading jika perlu
        } else if (state is Unauthenticated) {
          // TAMBAHKAN rootNavigator: true DI SINI
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
            Text(widget.user.nama_lengkap,
                style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.user.email, style: const TextStyle(color: AppColors.white)),
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
                    _buildMenuItem(Icons.person_outline, "Detail User", _showEditDialog),
                    _buildMenuItem(Icons.settings, "Pengaturan Profil", () {}),
                    _buildMenuItem(Icons.lock_outline, "Ganti Password", () {}),
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
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.orange),
      title: Text(title,
          style: TextStyle(
              color: isLogout ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}