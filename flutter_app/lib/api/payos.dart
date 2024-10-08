import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:payos_demo_flutter/type/create_payment_link_response.dart";
import "package:payos_demo_flutter/type/payment_status_response.dart";
import "package:payos_demo_flutter/type/deep_link_item_response.dart";
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<CreatePaymentLinkResponse> createPaymentLink() async {
  final response = await http
      .post(Uri.parse('${dotenv.env['BASE_URL']}/create-payment-link'));
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
  final response =
      await http.get(Uri.parse('${dotenv.env['BASE_URL']}/order/$orderCode'));
  if (response.statusCode == 200) {
    PaymentStatusResponse status = PaymentStatusResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
    return status;
  } else {
    throw Exception("Fail to get status");
  }
}

Future<List<DeepLinkItemResponse>> getDeepLinkList() async {
  final response = await http.get(Uri.parse(
      'https://api.vietqr.io/v2/${Platform.isAndroid ? 'android' : 'ios'}-app-deeplinks'));
  if (response.statusCode == 200) {
    List<dynamic> apps = jsonDecode(response.body)['apps'];
    List<DeepLinkItemResponse> res = apps.map((app) => DeepLinkItemResponse.fromJson(app) ).toList();
    return res;
  } else {
    throw Exception("Fail to get deep link list");
  }
}
