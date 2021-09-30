import 'package:acesse_vrm_flutter/views/initial_screen.dart';
import 'package:flutter/material.dart';

import 'views/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.urlSalva, this.usuario, this.senha})
      : super(key: key);
  final String? urlSalva, usuario, senha;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Acesse VRM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: urlSalva == null
            ? const InitialScreen()
            : MyHomePage(
                url: urlSalva,
                usuario: usuario,
                senha: senha,
              ),
        //Rotas nomeadas da aplicação.
        routes: <String, WidgetBuilder>{
          '/Home': (context) => const MyHomePage(),
          '/Initial': (context) => const InitialScreen(),
        });
  }
}
