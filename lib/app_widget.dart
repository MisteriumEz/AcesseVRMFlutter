import 'package:acesse_vrm_flutter/views/initial_screen.dart';
import 'package:flutter/material.dart';

import 'views/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.temDados}) : super(key: key);
  final bool? temDados;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Acesse VRM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const InitialScreen(),
        initialRoute: temDados! ? '/Home' : '/Login',
        //Rotas nomeadas da aplicação.
        routes: <String, WidgetBuilder>{
          '/Home': (context) => MyHomePage(),
          '/Initial': (context) => InitialScreen(),
        });
  }
}
