import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'Pelanggan';
        if (state is Authenticated) {
          username = state.user.nama_lengkap.trim().split(' ').first;
        }

        bool isAdmin = userRole == 'admin';

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
                          isAdmin ? Icons.qr_code_scanner_rounded : Icons.person_rounded,
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
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: const InputDecorationTheme(
                            hintStyle: TextStyle(color: AppColors.background),
                          ),
                        ),
                        child: CustomSearchBar(
                          controller: searchController,
                          hintText: isAdmin ? 'Cari pesanan kustomer...' : 'Cari burger favoritmu...',
                          onChanged: onSearchChanged,
                          onClear: onSearchClear,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onFilterOrScanTap,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isAdmin ? Icons.document_scanner_outlined : Icons.tune_rounded, // Tune_rounded adalah icon slider filter titik 3 melintang
                          color: AppColors.darkRed,
                          size: 22,
                        ),
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