import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_integration/keys.dart';

class StripeCardPayment extends StatefulWidget {
  const StripeCardPayment({super.key});

  @override
  State<StripeCardPayment> createState() => _StripeCardPaymentState();
}

class _StripeCardPaymentState extends State<StripeCardPayment> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await makePayment();
                try {
                  await Stripe.instance.presentPaymentSheet();
                } catch (e) {
                  print('error$e');
                }
              },
              child: const Text('Pay with Card'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('20000', 'pkr');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Ikram',
        ),
      );
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': stripeSecretKeyToken,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body.toString());
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }
}
