import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_search.dart';

class DashboardHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String userRole;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final VoidCallback? onRightActionTap;
  final VoidCallback? onFilterOrScanTap;

  const DashboardHeader({
    super.key,
    required this.searchController,
    required this.userRole,
    this.onSearchChanged,
    this.onSearchClear,
    this.onRightActionTap,
    this.onFilterOrScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userRole == 'admin';

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'Pelanggan';
        if (state is Authenticated) {
          username = state.user.nama_lengkap.trim().split(' ').first;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Atas: Profil & QR/Person Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $username!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAdmin
                                ? 'Pantau dan kelola pesanan kustomer hari ini'
                                : 'Yuk, pilih dan pesan burger favoritmu sekarang!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onRightActionTap,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.orange,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        controller: searchController,
                        hintText: isAdmin ? 'Cari pesanan customer' : 'Cari burger favoritmu...',
                        onChanged: onSearchChanged,
                        onClear: onSearchClear,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}