import 'package:flutter/material.dart';
import 'package:moburger/ui/order/history_order/user_history_order.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),
              const SizedBox(height: 20),

              const Text(
                "Pembayaran Berhasil",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Pesanan Anda sedang diproses",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const UserOrderHistoryScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Kembali ke Beranda"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}