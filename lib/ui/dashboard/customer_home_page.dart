import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_navbar.dart';
import 'package:moburger/core/widget/custom_search.dart';  // File bottom bar kamu

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  TabKey _activeTab = TabKey.home;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  
  final List<String> _categories = [
    'Semua', 
    'Burger', 
    'Minuman', 
    'Cemilan', 
    'Paket Puas'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, 
      body: _buildBodyContent(),
      bottomNavigationBar: CustomBottomBar(
        activeTab: _activeTab,
        userRole: 'customer',
        onTabPress: (TabKey selectedTab) {
          setState(() {
            _activeTab = selectedTab;
          });
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_activeTab) {
      case TabKey.home:
        return _buildHomeDashboardContent();
      case TabKey.menu:
        return const Center(child: Text('Katalog Menu MoBurger', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)));
      case TabKey.cart:
        return const Center(child: Text('Keranjang Belanja', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)));
      case TabKey.order:
        return const Center(child: Text('Riwayat Pesanan Anda', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)));
      case TabKey.profile:
        return const Center(child: Text('Profil Pengguna', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)));
      default:
        return _buildHomeDashboardContent();
    }
  }

  // ==================== STRUKTUR UTAMA DASHBOARD (HOME) ====================
  Widget _buildHomeDashboardContent() {
    return Column(
      children: [
        DashboardHeader(
          searchController: _searchController,
          userRole: 'customer',
          onSearchChanged: (val) {
          },
          onSearchClear: () {
            _searchController.clear();
          },
          onRightActionTap: () {
            setState(() => _activeTab = TabKey.profile); 
          },
          onFilterOrScanTap: () {
            
          },
        ),

        
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 2. WIDGET CAROUSEL IKLAN PROMO
                _buildPromoCarousel(),

                const SizedBox(height: 24),

                // 3. WIDGET KATEGORI MENU HORIZONTAL CHIPS
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Kategori Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryList(),

                const SizedBox(height: 24),

                // 4. WIDGET GRID VIEW LIST BURGER TERLARIS
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Menu Terlaris 🔥',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                _buildBestSellerGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== INLINE SUB-COMPONENTS (IKLAN, KATEGORI & GRID) ====================

  Widget _buildPromoCarousel() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: 3,
        controller: PageController(viewportFraction: 0.88),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: index == 0 ? AppColors.darkRed : AppColors.orange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  const Positioned(
                    right: -20,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(Icons.fastfood, size: 180, color: AppColors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(8)),
                          child: const Text('PROMO JUARA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 8),
                        const Text('Diskon Hingga 35%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('Khusus Pembelian via Aplikasi MoBurger', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              showCheckmark: false, // Menghilangkan ikon ceklis bawaan Flutter
              selectedColor: AppColors.darkRed,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.black12),
              ),
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestSellerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), 
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 4, 
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(child: Icon(Icons.lunch_dining_rounded, size: 70, color: AppColors.orange)),
                ),
                const Text(
                  'Cheese Burger Super',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                const Text('Daging sapi asli + keju lumer', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rp 32.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.orange)),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: AppColors.darkRed, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}