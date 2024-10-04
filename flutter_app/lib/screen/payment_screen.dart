import 'dart:async';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:payos_demo_flutter/api/payos.dart';
import 'package:payos_demo_flutter/screen/home_screen.dart';
import 'package:payos_demo_flutter/type/create_payment_link_response.dart';
import 'package:payos_demo_flutter/type/payment_status_response.dart';
import 'package:payos_demo_flutter/type/deep_link_item_response.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<PaymentScreen> createState() {
    return PaymentScreenState();
  }
}

WebViewEnvironment? webViewEnvironment;

class PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey webViewKey = GlobalKey();
  late Future<CreatePaymentLinkResponse> paymentLink;
  late Future<List<DeepLinkItemResponse>> deepLinkList;
  @override
  void initState() {
    super.initState();
    paymentLink = createPaymentLink();
    deepLinkList = getDeepLinkList();
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
            body: SingleChildScrollView(
              child: Center(
                child: FutureBuilder<CreatePaymentLinkResponse>(
                    future: paymentLink,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        CreatePaymentLinkResponse data = snapshot.data!;

                        InAppWebViewController? webViewController;
                        InAppWebViewSettings settings = InAppWebViewSettings(
                          isInspectable: kDebugMode,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          iframeAllow: "",
                          iframeAllowFullscreen: true,
                          useShouldOverrideUrlLoading: true,
                          useShouldInterceptRequest: false,
                        );

                        return Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            children: [
                              StreamBuilder<PaymentStatusResponse>(
                                  stream: Stream.periodic(Duration(seconds: 1))
                                      .asyncMap((i) =>
                                          getPaymentStatus(data.orderCode)),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<PaymentStatusResponse>
                                          snapshot) {
                                    if (snapshot.data != null) {
                                      dynamic result = snapshot.data?.data;
                                      if (result['status'] == "PAID" &&
                                          context.mounted) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          context.go('/success');
                                        });
                                      }
                                    }
                                    return Text("");
                                  }),
                              FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  placeholderColor: Colors.amber,
                                  width: 300,
                                  image:
                                      'https://img.vietqr.io/image/${data.bin}-${data.accountNumber}-vietqr_pro.png?amount=${data.amount}&addInfo=${data.description}&accountName=${data.accountName}'),
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
                                margin: EdgeInsets.only(top: 10, bottom: 10),
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
                              ),
                              Center(
                                child: Text(
                                  'Thanh toán bằng app ngân hàng',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                              FutureBuilder(
                                  future: getDeepLinkList(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      List<DeepLinkItemResponse> list =
                                          snapshot.data!;
                                      print(list.length);
                                      return Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        spacing: 3.0,
                                        runSpacing: 1,
                                        children: <Widget>[
                                          for (DeepLinkItemResponse item
                                              in list)
                                            BankButton(
                                                bgColor: Colors.transparent,
                                                textColor: Colors.black,
                                                label: item.appId.toUpperCase(),
                                                bankId: item.appId,
                                                amount: data.amount.toString(),
                                                bankLogo: item.appLogo,
                                                accountNo:
                                                    '${data.accountNumber}@${data.bin}',
                                                des: data.description)
                                        ],
                                      );
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("Loading...");
                                    } else {
                                      return Text("Something went wrong");
                                    }
                                  }),

                              // Expanded(
                              //     flex: 1,
                              //     child: InAppWebView(
                              //       key: webViewKey,
                              //       webViewEnvironment: webViewEnvironment,
                              //       initialUrlRequest: URLRequest(
                              //           url: WebUri(data.checkoutURl)),
                              //       shouldOverrideUrlLoading: (controller,
                              //           navigationAction) async {
                              //         final url = await controller.getUrl();
                              //         final deeplink =
                              //             navigationAction.request.url;
                              //         debugPrint('Deeplink query');
                              //         final status = deeplink?.queryParameters['status'];
                              //         if(status == 'CANCELLED' && context.mounted){
                              //           context.go('/cancel');
                              //         }
                              //         debugPrint(deeplink?.host);
                              //         debugPrint(url.toString());
                              //         if (deeplink != null &&
                              //             url != deeplink &&
                              //             (deeplink.scheme != 'https' &&
                              //                 deeplink.scheme != 'http')) {
                              //           if (await canLaunchUrl(deeplink)) {
                              //             await launchUrl(
                              //                 WebUri(
                              //                     '${dotenv.env['OCB_DEEP_LINK']}'),
                              //                 mode: LaunchMode
                              //                     .externalNonBrowserApplication);
                              //           }
                              //           return NavigationActionPolicy
                              //               .CANCEL;
                              //         }
                              //         return NavigationActionPolicy.ALLOW;
                              //       },
                              //       initialSettings: settings,
                              //       onWebViewCreated: (controller) {
                              //         webViewController = controller;
                              //       },
                              //       onProgressChanged: (controller, url) async {

                              //       },
                              //     )),
                            ],
                          ),
                        );
                      }
                      return const CircularProgressIndicator(
                        backgroundColor: Colors.redAccent,
                      );
                    }),
              ),
            )));
  }
}

// ignore: must_be_immutable
class BankButton extends StatelessWidget {
  final String label;
  final String bankId;
  final String amount;
  final String bankLogo;
  final String accountNo;
  final String des;
  late Color? bgColor;
  late Color? textColor;

  BankButton(
      {super.key,
      required this.label,
      this.bgColor,
      this.textColor,
      required this.bankId,
      required this.amount,
      required this.bankLogo,
      required this.accountNo,
      required this.des});
  @override
  Widget build(BuildContext context) {
    const redirectUrl = 'https://payos-flutter-demo.netlify.app/success';
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 85.0, minWidth: 85.0),
      child: TextButton(
        onPressed: () async {
          final deepLink = Uri.parse(
              'https://dl.vietqr.io/pay?app=${bankId}&ba=$accountNo&am=$amount&tn=$des&redirect_url=$redirectUrl');
          // final deepLink = Uri.parse(
          //     'newomni-app://CASSO/00020101021238540010A00000072701240006970422011003697645770208QRIBFTTA53037045405100005802VN62080804test63044647?redirect_url=https%3A%2F%2Fpayos-flutter-demo.netlify.app×tamp=1727947904394&signature=Mv%2FuWEx9UX%2BbR9bYQTZ%2Bm4w6DJID1RYSGXgPHcExR6ullppznryhVJPl24yxoTbQdIP5pAOAeaz24OU9E5WrjVnCamxq2Ny%2FuIRJ9bM82eDN0b5YvTQJGddmyj%2FuBZ6KUAUMKJRNVFlF2bq6SmXo09DZBHOtrrB4P3qfsTLpApiq%2FzWyIPz7HSzVJwTKgLrLYiH3QBfOFtedh6dzRneZ7k%2F1QaDAC6k9wBOUT4fUcBoYfJtFOPuj%2FYHcg41kbKVqirW0JXGFquQfN2eUohW48wDEtBpEmC5GerkGhDA%2FPherm%2FgHslqud%2BCACWx8gdJknT2LIL4i6klG1EUFleJEL%2F7lySIkOuCeLyVWNBZVq5xM4Ta3Odt4gw%2FfwTdlBSWWVJAfjECEzIb52DB7%2BmdqEOrPdFhUbkiKWWrGoj2FGy6bAWx2cqYxSqUCMzmfZPRP0KKentn0xT0GZFfSBJsfWb8rjKw4JFKeuLUGtzCSEHTKJDP7XkklRN8N5HNpEtJBntK146IUtnd8xMQD11iEq0LHwMVxFKPrVGyOWSGKmf7ueLr6DEye%2BPnHlyONDgXdKOUy07tvp9XC173Q1WVWb%2F%2BrCSy4q4AJl0RIxt4gC506ELQEe%2B%2F7n9a8fFJvN0DQbM53RWb%2FHYebsF3dbv1oI%2FpA%2B8L5teSbvFgw%2FYTZSws%3D');
          if (await canLaunchUrl(deepLink)) {
            await launchUrl(deepLink, mode: LaunchMode.externalApplication);
          }
        },
        style: TextButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  placeholderColor: Colors.amber,
                  width: 45,
                  image: bankLogo),
            ),
            Container(
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.black12, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              margin: EdgeInsets.only(top: 3),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
