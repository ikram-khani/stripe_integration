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
                await initPayment();
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

  Future<void> initPayment() async {
    try {
      paymentIntentData = await createPaymentIntent(298.89, 'USD');
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

  createPaymentIntent(double amount, String currency) async {
    try {
      //convert to cents because the stripe accepts the payments in smallest currency unit(cents, paisa etc) and then it shows in dollar or rupee on ui
      int amountInCents = (amount * 100).round();
      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
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
      print(jsonDecode(response.body.toString()));
      return jsonDecode(response.body.toString());
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }
}
