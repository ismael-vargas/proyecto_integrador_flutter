import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'firebase_options.dart'; // Importa el archivo generado por FlutterFire CLI
import 'login.dart';
import 'registro.dart';
import 'inicio.dart';
import 'admin_inicio.dart'; // Importar la pantalla de administración

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/registro': (context) => const Registro(),
        '/inicio': (context) => InicioScreen(),
        '/admin_inicio': (context) => AdminInicioScreen(), // Se eliminó 'const'
      },
    );
  }
}
