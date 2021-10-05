// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:acesse_vrm_flutter/styles/styles.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

import 'lost_net_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.url, this.usuario, this.senha})
      : super(key: key);
  final String? url, usuario, senha;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? urlAtiva, usuario, senha;
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  String? codigoBarras;
  List<GlobalKey<FormState>> formKey = [GlobalKey(), GlobalKey(), GlobalKey()];

  @override
  void initState() {
    super.initState();
    urlAtiva = widget.url;
    usuario = widget.usuario;
    senha = widget.senha;
    sharedPrefs();

    //urlAtiva = "http://10.0.0.146:9090/acessevrm/";
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  Future<void> sharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    usuario = prefs.getString("usuario");
    senha = prefs.getString("senha");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Acesse VRM"),
          leading: const Image(
            image: AssetImage('assets/images/LogoBrasil.png'),
          ),
          actions: [
            IconButton(
              tooltip: "Recarregue a página",
              onPressed: () {
                webViewController?.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: "Escaneie o QRCode novamente",
              onPressed: () {
                _scanQRcode();
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: Uri.parse(urlAtiva!)),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        ///Responsável por puxar
                        controller.addJavaScriptHandler(
                            handlerName: "login",
                            callback: (loginJSON) {
                              var jsonLoginficado = json.decode(loginJSON[0]);
                              var usuario = jsonLoginficado['usuario'];
                              var senha = jsonLoginficado['senha'];
                              setVariavelLogin(usuario, senha);
                              print("EU TO LOCO, TO LOGADo $loginJSON");
                            });

                        ///Handler responsável por puxar e injetar o código de
                        ///barras no VRM
                        controller.addJavaScriptHandler(
                            handlerName: "codebar",
                            callback: (metodoWeb) {
                              var metodoWebficado = json.decode(metodoWeb[0]);
                              var numeroMetodo = metodoWebficado['param_nome'];
                              print("ME CHAMARAM PRA LER UM CÓDIGO $metodoWeb");
                              _scanBarcode(numeroMetodo);
                            });

                        ///Compartilha o pdf via Share Sheet
                        controller.addJavaScriptHandler(
                            handlerName: "compartilharOutrasOpcoes",
                            callback: (arquivo) {
                              var arquivoJson = json.decode(arquivo[0]);
                              var arquivoResposta = arquivoJson['arquivo'];
                              createPdf(arquivoResposta).then((value) {
                                Share.shareFiles([value]);
                                print("Acabou o sossego meu mano");
                              });
                              //var decoded =
                              //  utf8.decode(base64.decode(numeroMetodo));
                              print(
                                  "ME CHAMARAM PRA DECODIFICAR UM PDF $arquivoJson");
                            });

                        ///Compartilha o pdf via Whatsapp
                        controller.addJavaScriptHandler(
                            handlerName: "compartilharViaWhats",
                            callback: (arquivo) {
                              var arquivoJson = json.decode(arquivo[0]);
                              var arquivoResposta = arquivoJson['arquivo'];
                              createPdf(arquivoResposta).then((value) {
                                shareFileViaZap(value);
                              });
                              //var decoded =
                              //  utf8.decode(base64.decode(numeroMetodo));
                              print(
                                  "ME CHAMARAM PRA DECODIFICAR UM PDF $arquivoJson");
                            });

                        ///Compartilha o item via Whatsapp
                        controller.addJavaScriptHandler(
                            handlerName: "compartilharItem",
                            callback: (mensagem) {
                              var mensagemJson = json.decode(mensagem[0]);
                              var mensagemResposta =
                                  mensagemJson['param_message'];

                              _colocaNumero(mensagemResposta);

                              print(
                                  "ME CHAMARAM PARA ENVIAR UM ITEM $mensagemResposta");
                            });

                        webViewController = controller;
                      },
                      onDownloadStart: (controller, url) {
                        print("TESTE");
                        //_downloadTask(url.path);
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunch(url)) {
                            // Launch the App
                            await launch(
                              url,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController.endRefreshing();
                        if (usuario != null && senha != null) {
                          var login = "javascript:login('$usuario', '$senha');";
                          controller.evaluateJavascript(source: login);
                        }
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController.endRefreshing();
                        print("SEM INTERNET OU SERVIDOR CAIU IRMAO");
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => SemInternet(
                                url: urlAtiva!,
                                usuario: widget.usuario,
                                senha: widget.senha,
                              ),
                            ),
                            (route) => false);
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = this.url;
                        });
                      },
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Void que coloca o número do Whatsapp e envia o item para o mesmo número
  void _colocaNumero(String mensagem) {
    var numeroZapController = MaskedTextController(mask: "(00)0000-00000");
    var focus = FocusNode();

    int? contador;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          child: Form(
            key: formKey[1],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AlertDialog(
              title: Text(
                "Número do telefone",
                style: TextStyle(fontSize: 14),
              ),
              content: Padding(
                padding: EdgeInsets.all(8),
                child: KeyboardListener(
                  focusNode: focus,
                  onKeyEvent: (value) {
                    if (value.logicalKey.keyLabel == "Backspace") {
                      numeroZapController.updateMask("(00)0000-00000");
                    }
                  },
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText:
                            "Insira aqui o número para que deseja enviar"),
                    maxLength: 14,
                    validator: (value) {
                      if (value!.length < 13) {
                        return "Número muito curto";
                      } else {
                        if (value.length == 13) {
                          numeroZapController.updateMask("(00)00000-0000");
                        }
                        contador = value.length;
                        print(contador);
                        return null;
                      }
                    },
                    controller: numeroZapController,
                  ),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    final isValid = formKey[1].currentState?.validate();
                    if (isValid!) {
                      launchWhatsapp(
                          numeroZapController.text
                              .replaceAll("(", "")
                              .replaceAll(")", "")
                              .replaceAll("-", ""),
                          mensagem.replaceAll(" ", "%20"));
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Confirmar"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///Scanneador do código de barras
  Future<void> _scanQRcode() async {
    try {
      var qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#00d1ff',
        'Cancelar',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;
      if (qrCode != "-1") {
        print(qrCode);

        setState(() {
          if (Platform.isAndroid) {
            webViewController?.loadUrl(
              urlRequest: URLRequest(
                url: Uri.parse(qrCode),
              ),
            );
          } else if (Platform.isIOS) {
            webViewController?.loadUrl(
              urlRequest: URLRequest(
                url: Uri.parse(qrCode),
              ),
            );
          }
        });
      }
    } on PlatformException {
      print("Deu ruim");
    }
  }

  ///Scanneador do código de barras
  Future<void> _scanBarcode(String metodoWebView) async {
    try {
      var barCode = await FlutterBarcodeScanner.scanBarcode(
        '#14D400',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );

      if (!mounted) return;
      if (barCode != "-1") {
        print(barCode);

        setState(() {
          codigoBarras = barCode;
          var sendToJavaScript = "metodoWebView$metodoWebView($codigoBarras)";

          webViewController!.evaluateJavascript(source: sendToJavaScript);
        });
      }
    } on PlatformException {
      print("Deu ruim");
    }
  }

  ///Seta as variavéis de login no banco para que sejam chamadas quando o usuário
  ///logar uma segunda vez
  setVariavelLogin(usuario, senha) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("usuario", usuario);
    prefs.setString("senha", senha);
    print("Usuário e senha guardados");
  }

  ///Quando o botão de voltar for pressionado
  Future<bool> _onBackPressed() async {
    print("TESTE");
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: headerErrorColor,
        content: const Text('Utilize os botões do aplicativo'),
        action: SnackBarAction(
            textColor: Colors.white,
            label: 'Fechar',
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
    return false;
  }

  ///Cria o PDF decodificando o base64 que vem do VRM
  Future<String> createPdf(String retornoServidor) async {
    var nomeArquivo = retornoServidor.substring(1, 10);
    var bytes = base64Decode(retornoServidor);
    var output = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File("${output!.path}/${nomeArquivo}_orcamento.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    setState(() {});
    return "${output.path}/${nomeArquivo}_orcamento.pdf";
  }

  ///Compartilha o arquivo via Zap sem precisar do contato salvo = SÓ ANDROID
  Future<void> shareFileViaZap(String path) async {
    var telefone = '75';
    print(path);
    await WhatsappShare.shareFile(
      phone: "55$telefone",
      filePath: [path],
    );
  }

  _downloadTask(urlDownload) async {
    Directory? diretorio = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    FlutterDownloader.initialize().then((value) async {
      final taskId = await FlutterDownloader.enqueue(
          url: urlDownload,
          savedDir: "${diretorio!.path}/",
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification: true);
    });
  }

  ///Manda a mensagem que vem do request do Compartilhar Item, verificar depois
  ///se está funcionando corretamente
  Future<void> launchWhatsapp(numero, mensagem) async {
    var _urlWhatsapp =
        'https://api.whatsapp.com/send?phone=+55$numero&text=$mensagem';
    await canLaunch(_urlWhatsapp)
        ? await launch(_urlWhatsapp)
        : throw 'Deu erro negão';
  }
}
