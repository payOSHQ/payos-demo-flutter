import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payos_demo_flutter/api/payos.dart';
import 'package:payos_demo_flutter/screen/home_screen.dart';
import 'package:payos_demo_flutter/type/create_payment_link_response.dart';
import 'package:payos_demo_flutter/type/payment_status_response.dart';
import 'package:transparent_image/transparent_image.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<PaymentScreen> createState() {
    return PaymentScreenState();
  }
}

class PaymentScreenState extends State<PaymentScreen> {
  late Future<CreatePaymentLinkResponse> paymentLink;

  @override
  void initState() {
    super.initState();
    paymentLink = createPaymentLink();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Detail Payment'),
              leading: IconButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  icon: const Icon(Icons.arrow_back)),
            ),
            body: Center(
              child: FutureBuilder<CreatePaymentLinkResponse>(
                  future: paymentLink,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      CreatePaymentLinkResponse data = snapshot.data!;
                      return StreamBuilder<PaymentStatusResponse>(
                          stream: Stream.periodic(Duration(seconds: 5))
                              .asyncMap(
                                  (i) => getPaymentStatus(data.orderCode)),
                          builder: (BuildContext context,
                              AsyncSnapshot<PaymentStatusResponse> snapshot) {
                            // PaymentStatusResponse status = snapshot.data!;
                            if (snapshot.data != null) {
                              dynamic result = snapshot.data?.data;
                              debugPrint(result['status']);
                              if(result['status'] == "PAID"){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Thanh toan thanh cong", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                                    TextButton(onPressed: () => {context.go('/')}, style: TextButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0)
                                    ), child: Text("Quay lại màn hình chính", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),))
                                  ],
                                );
                              }
                            }
                            return Container(
                              padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                              child: Column(
                                children: [
                                  FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      placeholderColor: Colors.amber,
                                      width: 300,
                                      image:
                                          'https://img.vietqr.io/image/${data.bin}-${data.accountNumber}-qr_only.png?amount=${data.amount}&addInfo=${data.description}&accountName=${data.accountName}'),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.white38,
                                          width: 0.5,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(-1, 1),
                                        ),
                                      ],
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsetsDirectional.all(10),
                                    margin: EdgeInsets.only(top: 10),
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        CustomInfo(
                                            label: "Account Name:",
                                            info: data.accountName),
                                        CustomInfo(
                                            label: "Account Number:",
                                            info: data.accountNumber),
                                        CustomInfo(
                                            label: "Amount:",
                                            info: data.amount.toString()),
                                        CustomInfo(
                                            label: "Description:",
                                            info: data.description),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    }
                    return const CircularProgressIndicator(
                      backgroundColor: Colors.redAccent,
                    );
                  }),
            )));
  }
}
