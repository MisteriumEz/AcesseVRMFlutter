// ignore_for_file: prefer_const_constructors

import 'package:acesse_vrm_flutter/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class SemInternet extends StatefulWidget {
  const SemInternet({Key? key, required this.url, this.usuario, this.senha})
      : super(key: key);

  final String url;
  final String? usuario, senha;

  @override
  _SemInternetState createState() => _SemInternetState();
}

class _SemInternetState extends State<SemInternet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          color: headerErrorColor,
        ),
        preferredSize: Size.fromHeight(0.0),
      ),
      body: noNotesUI(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: headerErrorColor,
        onPressed: () {
          _scanQRcode();
        },
        child: (Icon(Icons.qr_code)),
      ),
    );
  }

  ///░C░o░l░o░c░a░r░ ░a░ ░f░o░t░o░ ░d░o░s░ ░3░ ░t░r░i░â░n░g░u░l░o░s░ ░a░q░u░i░
  Widget noNotesUI(BuildContext context) {
    return ListView(
      children: [
        header(),
        Column(
          children: [
            /* 
           PRECISAMENTE A FOTO VEM AQUIS
           Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
                'assets/images/ICONE-BRASIL.png',
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ), */
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: noNotesStyle,
                  children: [
                    TextSpan(
                        text:
                            "Verifique sua conexão com a internet e servidor e"),
                    TextSpan(
                        text: ' Clique aqui ',
                        style: boldPlus2,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(
                                    url: widget.url,
                                  ),
                                ),
                                (route) => false);
                          }),
                    TextSpan(
                        text:
                            'para tentar se reconectar. \n\nCaso não funcione tente ler o QR Code novamente no botão abaixo.'),
                  ],
                ),
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
          color: headerErrorColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(75.0),
            bottomLeft: Radius.circular(75.0),
          ),
        ),
        height: 150,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ERRO',
              style: headerRideStyle,
            ),
            Text(
              '404',
              style: headerNotesStyle,
            ),
          ],
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
                usuario: widget.usuario,
                senha: widget.senha,
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
}
