import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Demo Embedded Link'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(0),
              margin:
                  EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: Column(
                      children: [
                        CustomInfo(
                            label: "Tên sản phẩm: ", info: "Mì tôm hảo hảo"),
                        CustomInfo(label: "Giá tiền: ", info: "2,000 VND"),
                        CustomInfo(label: "Số lượng: ", info: "1"),
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: () => {
                        context.push('/payment')
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text(
                        "Tạo link thanh toán",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInfo extends StatelessWidget {
  final String label;
  final String info;
  const CustomInfo({super.key, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              info,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
}
