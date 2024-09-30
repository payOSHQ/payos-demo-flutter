import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:payos_demo_flutter/type/create_payment_link_response.dart";
import "package:payos_demo_flutter/type/payment_status_response.dart";
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<CreatePaymentLinkResponse> createPaymentLink() async {
  debugPrint(dotenv.env['BASE_URL']);
  final response = await http.post(Uri.parse('${dotenv.env['BASE_URL']}/create-payment-link'));
  debugPrint(response.body);
  if (response.statusCode == 200) {
    CreatePaymentLinkResponse responseData = CreatePaymentLinkResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
    return responseData;
  } else {
    throw Exception("FAIL to load");
  }
}

Future<PaymentStatusResponse> getPaymentStatus(int orderCode) async {
  await dotenv.load();
  final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/order/$orderCode'));
  if (response.statusCode == 200) {
    PaymentStatusResponse status = PaymentStatusResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
    return status;
  } else {
    throw Exception("Fail to get status");
  }
}
