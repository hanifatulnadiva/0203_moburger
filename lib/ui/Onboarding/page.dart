import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_dot_indikator.dart';
import 'package:moburger/ui/auth/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentCarousel = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Cari Burger',
      'subtitle': 'Jelajahi dan pilih varian burger premium dengan cita rasa terbaik langsung dari smartphone Anda.',
      'asset': 'assets/cari.png',
    },
    {
      'title': 'Easy Payment',
      'subtitle': 'Selesaikan pembayaran secara kilat dan aman menggunakan e-wallet favorit pilihan Anda.',
      'asset': 'assets/pembayaran.png',
    },
    {
      'title': 'Ambil Sendiri',
      'subtitle': 'Pantau proses memasak di dapur, lalu ambil pesanan Anda langsung di konter tanpa perlu mengantre.',
      'asset': 'assets/pengambilan.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: _currentCarousel < _onboardingData.length - 1
                    ? TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentCarousel = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  final bool isSvg = item['asset']!.endsWith('.svg');

                  return Padding( 
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 260,
                          child: isSvg
                              ? SvgPicture.asset(
                                  item['asset']!,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  item['asset']!,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomDotIndicator(
                    count: _onboardingData.length,
                    currentIndex: _currentCarousel,
                    activeColor: AppColors.orange,
                    inactiveColor: Colors.black12,
                  ),
                  _currentCarousel == _onboardingData.length - 1
                      ? SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            onPressed: _navigateToLogin,
                            child: const Text(
                              "Let's Start",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}