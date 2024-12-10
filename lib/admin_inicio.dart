import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firestore
import 'admin_tickets.dart'; // Importar archivo de gestión de tickets
import 'admin_usuarios.dart'; // Importar archivo de gestión de usuarios
import 'leer_qr.dart'; // Asegúrate de que la ruta sea correcta


class AdminInicioScreen extends StatefulWidget {
  @override
  _AdminInicioScreenState createState() => _AdminInicioScreenState();
}

class _AdminInicioScreenState extends State<AdminInicioScreen> {
  User? user; // Variable para almacenar el usuario logueado
  String? userName = '';
  String? userEmail = '';
  String? userInitials = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos del usuario logueado
  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        userEmail = currentUser.email;
      });

      // Obtener datos adicionales desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (mounted && userDoc.exists) {
        setState(() {
          userName = '${userDoc['nombre']} ${userDoc['apellido']}';
          userInitials = _getInitials(userDoc['nombre'], userDoc['apellido']);
        });
      }
    }
  }

  // Función para calcular las iniciales del nombre
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  // Función para cerrar sesión
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // Redirige a Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.blue[900],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[900]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      userInitials ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName ?? 'Administrador',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userEmail ?? 'admin@app.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Gestionar Tickets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminTicketsPage()),
                );
              },
            ),


// Añadir esta parte en tu Drawer dentro de admin_inicio.dart
ListTile(
  leading: Icon(Icons.qr_code_scanner),
  title: Text('Leer Código QR'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeerQRScreen()),
    );
  },
),









            ListTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text('Gestionar Usuarios'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUsuarios()),
                );
              },
              
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.blue[900]),
            SizedBox(height: 20),
            Text(
              '¡Bienvenido al Panel de Administración!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 10),
            Text(
              'Gestione usuarios, tickets y servicios de manera eficiente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blue[600]),
            ),
          ],
        ),
      ),
    );
  }
}
