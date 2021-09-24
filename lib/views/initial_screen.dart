// ignore_for_file: prefer_const_constructors

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 2,
            child: Image.asset("assets/images/ICONE-BRASIL.png"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: AutoSizeText(
                "Para realizar a configuração inicial aperte o botão abaixo e leia o QR Code do seu servidor.",
                maxLines: 5,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 100,
              height: 100,
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(
                  Icons.qr_code_scanner,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  ///Scanneador do código de barras
  Future<void> _scanQRcode() async {
    try {
      var qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#010101',
        'Cancelar',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;
      print(qrCode);
      setState(() {});
    } on PlatformException {
      // ignore: avoid_print
      print("Deu ruim");
    }
  }
}
