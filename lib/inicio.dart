import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firestore
import 'ticket.dart'; // Importar archivo de tickets
import 'perfil.dart'; // Importar archivo de perfil
import 'mision-vision.dart'; // Importar archivo de misión y visión
import 'sucursales.dart'; // Importar archivo de sucursales

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  User? user; // Variable para almacenar el usuario logueado
  String? userName = '';
  String? userEmail = '';
  String? userInitials = '';
  List<Map<String, dynamic>> tickets = []; // Lista para almacenar los tickets

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTickets(); // Cargar los tickets cuando la pantalla se inicie
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['nombre'] + ' ' + userDoc['apellido'];
          // Calcular las iniciales
          userInitials = _getInitials(userDoc['nombre'], userDoc['apellido']);
        });
      }
    }
  }

  // Cargar los tickets desde Firestore
  Future<void> _loadTickets() async {
    final snapshot = await FirebaseFirestore.instance.collection('tickets').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get();
    setState(() {
      tickets = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
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
    Navigator.pushReplacementNamed(context, '/login'); // Redirige a Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.blue[900], // Azul oscuro
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bienvenido',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userEmail ?? 'usuario@app.com', // Mostrar el correo del usuario
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Generar Ticket'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketsPage(), // Redirige a la página de tickets
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilScreen(), // Redirige a la pantalla de perfil
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Misión y Visión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MisionVisionScreen(), // Redirige a misión y visión
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Sucursales'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SucursalesScreen(), // Redirige a la pantalla de sucursales
                  ),
                );
              },
            ),
            Divider(), // Línea divisoria
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _signOut(); // Cierra sesión y redirige a Login
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ac_unit, size: 100, color: Colors.blue[900]), // Icono
            SizedBox(height: 20),
            Text(
              '¡Bienvenido a la app de Aires Acondicionados!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Gestione tickets y servicios de manera eficiente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blue[600]),
            ),
          ],
        ),
      ),
    );
  }
}
