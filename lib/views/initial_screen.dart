// ignore_for_file: prefer_const_constructors

import 'package:acesse_vrm_flutter/styles/styles.dart';
import 'package:acesse_vrm_flutter/views/home_screen.dart';
//import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
            Colors.blue.shade300,
            Colors.blue,
            Colors.blue.shade900
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: noNotesUI(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _scanQRcode();
          },
          child: Icon(Icons.qr_code),
        ),
      ),
    );
  }

  ///Scanneador do código de barras
  Future<void> _scanQRcode() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#00d1ff',
        'Cancelar',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;
      if (qrCode != "-1") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                url: qrCode,
              ),
            ),
            (route) => false);
        prefs.setString("urlSalva", qrCode);
        print(qrCode);
        setState(() {});
      }
    } on PlatformException {
      // ignore: avoid_print
      print("Deu ruim");
    }
  }

  Widget noNotesUI(BuildContext context) {
    return ListView(
      children: [
        header(),
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: noNotesStyle,
                children: [
                  TextSpan(text: "Para realizar a configuração inicial"),
                  TextSpan(
                      text: ' aperte aqui ',
                      style: boldPlus,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _scanQRcode();
                        }),
                  TextSpan(text: 'e leia o QR Code do seu servidor.'),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget header() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(75.0),
          ),
        ),
        height: 150,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Image.asset(
                  'assets/images/ICONE-BRASIL.png',
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: 150,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
