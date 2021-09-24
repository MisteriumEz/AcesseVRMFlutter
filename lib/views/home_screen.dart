import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.url}) : super(key: key);
  final String? url;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acesse VRM"),
        leading: const Image(
          image: AssetImage('assets/images/LogoBrasil.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _scanQRcode();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
            print(WebView().userAgent);
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }

  ///Scanneador do código de barras
  Future<void> _scanBarcode() async {
    try {
      var barcode = await FlutterBarcodeScanner.scanBarcode(
        '#010101',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );

      if (!mounted) return;

      setState(() {
        if (barcode != "" && barcode != "-1") {
          if (barcode.length == 12) {
            barcode = '0' + barcode;
          }
        }
      });
    } on PlatformException {
      // ignore: avoid_print
      print("Deu ruim");
    }
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
