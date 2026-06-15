import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moburger/ui/order/order_detail/sukses_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderNumber;

  const MidtransWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
  });

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController controller;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl));

    startCheckingPayment();
  }

  void startCheckingPayment() {
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        try {
          final data = await Supabase.instance.client
              .from('order')
              .select('payment_status')
              .eq('order_number', widget.orderNumber)
              .single();

          print(data);

          if (data['payment_status'] == 'settlement') {
            timer?.cancel();

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const SuccessScreen(),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}