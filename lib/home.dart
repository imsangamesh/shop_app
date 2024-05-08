import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((_) => Stripe.instance.confirmPaymentSheetPayment())
          .then(
            (_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paid Successfully!')),
            ),
          )
          .onError((error, stackTrace) => throw Exception(error));
    } catch (e) {
      log('STRIPE ERROR: $e');
    }
  }

  Future<void> makePayment(BuildContext context) async {
    try {
      final paymentIntentData = await createPaymentIntent('9600', 'INR') ?? {};

      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              style: ThemeMode.light,
              customFlow: false,
              merchantDisplayName: 'Pinkkinlin',
            ),
          )
          .then((value) => Stripe.instance.confirmPaymentSheetPayment())
          .then((value) => displayPaymentSheet(context));
    } catch (e) {
      log('ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Integration')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => displayPaymentSheet(context),
          child: const Text('Pay!'),
        ),
      ),
    );
  }
}

dynamic createPaymentIntent(String amount, String currency) async {
  final resp = await http.post(
    Uri.parse('http://192.168.186.210:3000/api/payment'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'amount': amount, 'currency': currency},
  );

  return jsonDecode(resp.body);
}
