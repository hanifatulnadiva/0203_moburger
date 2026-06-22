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

  // ─── Dialog Edit Profil ───────────────────────────────────────────────────
  void _showEditDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          // Supaya dialog naik saat keyboard muncul
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.darkRed,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_outline,
                            color: AppColors.yellow, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Edit Profil",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close,
                              color: AppColors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("Nama Lengkap"),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _nameController,
                          hintText: "Masukkan nama lengkap",
                          prefixIcon: Icons.person,
                          validator: (val) => (val == null || val.isEmpty)
                              ? "Nama tidak boleh kosong"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _sectionLabel("Nomor HP"),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _phoneController,
                          hintText: "Masukkan nomor HP",
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (val) =>
                              (val == null || val.length < 10)
                                  ? "No HP tidak valid"
                                  : null,
                        ),
                        const SizedBox(height: 24),

                        // ── Tombol ─────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                      color: AppColors.darkRed),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(
                                      color: AppColors.darkRed,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          UpdateProfileRequested(
                                            id: widget.user.id,
                                            namaLengkap: _nameController.text,
                                            nohp: _phoneController.text,
                                          ),
                                        );
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Simpan",
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
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

  // ─── Dialog Ganti Password ────────────────────────────────────────────────
  void _showChangePassword() {
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 24),
                      decoration: const BoxDecoration(
                        color: AppColors.darkRed,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lock_outline,
                                color: AppColors.yellow, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Ganti Password",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close,
                                  color: AppColors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Body ─────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info tip
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.yellow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.yellow.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: AppColors.orange, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Password minimal ${AppConstants.minPasswordLength} karakter",
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _sectionLabel("Password Baru"),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: passwordController,
                              hintText: "Masukkan password baru",
                              prefixIcon: Icons.lock,
                              obscureText: obscureNew,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureNew
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setStateSheet(
                                    () => obscureNew = !obscureNew),
                              ),
                              validator: (val) {
                                if (val == null ||
                                    val.length <
                                        AppConstants.minPasswordLength) {
                                  return "Minimal ${AppConstants.minPasswordLength} karakter";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _sectionLabel("Konfirmasi Password"),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: confirmPasswordController,
                              hintText: "Ulangi password baru",
                              prefixIcon: Icons.lock_outline,
                              obscureText: obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setStateSheet(
                                    () => obscureConfirm = !obscureConfirm),
                              ),
                              validator: (val) {
                                if (val != passwordController.text) {
                                  return "Password tidak cocok";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ── Tombol ──────────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      side: const BorderSide(
                                          color: AppColors.darkRed),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Batal",
                                      style: TextStyle(
                                          color: AppColors.darkRed,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              ChangePasswordRequested(
                                                  passwordController.text),
                                            );
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.orange,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      "Update",
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
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
      },
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading:
          Icon(icon, color: isLogout ? AppColors.error : AppColors.orange),
      title: Text(title,
          style: TextStyle(
              color:
                  isLogout ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentUser =
            (state is Authenticated) ? state.user : widget.user;

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.darkRed,
            appBar: AppBar(
              title: const Text("Profil",
                  style: TextStyle(color: AppColors.white)),
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
                Text(currentUser.nama_lengkap,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(currentUser.email,
                    style: const TextStyle(color: AppColors.white)),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildMenuItem(Icons.info_outline, "Tentang Moburger",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()),
                          );
                        }),
                        _buildMenuItem(
                            Icons.person_outline, "Detail User", _showEditDialog),
                        _buildMenuItem(
                            Icons.lock_outline, "Ganti Password", _showChangePassword),
                        const Divider(color: AppColors.textSecondary),
                        _buildMenuItem(Icons.logout, "Keluar", _handleLogout,
                            isLogout: true),
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