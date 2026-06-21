import 'package:flutter/material.dart';
import 'package:moburger/core/contants/app_contants.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moburger/core/contants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Fungsi membuka WhatsApp
  Future<void> _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/6283896735071');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps() async {
    final Uri mapUrl = Uri.parse('https://maps.app.goo.gl/afYk4Fn4GiCy8rqu8');
    
    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Tidak bisa membuka maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tentang Moburger", style: AppTextStyles.judul),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: Icon(Icons.restaurant_menu, size: 80, color: AppColors.orange),
            ),
            const SizedBox(height: 20),
            Text(AppConstants.appName, style: AppTextStyles.headingBold),
            Text("Versi ${AppConstants.appVersion}", style: AppTextStyles.bodyRegular),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("Lokasi Kami", style: AppTextStyles.judul),
                  const SizedBox(height: 10),
                  Text(
                    "Jl. Brawijaya, Tamantirto, Kec. Kasihan, Kabupaten Bantul, Daerah Istimewa Yogyakarta 55183 (Kampus UMY)",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _launchMaps,
                    icon: const Icon(Icons.map, color: AppColors.orange),
                    label: const Text("Lihat di Peta", style: AppTextStyles.bodyOrange),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.support_agent, color: AppColors.orange),
              title: const Text("Hubungi Admin", style: AppTextStyles.judul),
              subtitle: const Text("Tanya jawab atau komplain pesanan"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _launchWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}