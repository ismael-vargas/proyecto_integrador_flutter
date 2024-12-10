import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firebase Firestore

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  // ignore: unused_field
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrarse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900], // Azul oscuro para la AppBar
      ),
      body: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -60,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.blue[100]!.withOpacity(0.5),
            ),
          ),
          Positioned(
            top: 150,
            right: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.blue[100]!.withOpacity(0.5),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -40,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.blue[100]!.withOpacity(0.5),
            ),
          ),

          // Contenido principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Comienza aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 82, 150),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logo envuelto con un contenedor
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/frigo.jpeg',
                        height: 120,
                        width: 120,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildTextField('Nombre', Icons.person, _nombreController),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Apellido', Icons.person_outline, _apellidoController),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Correo electrónico', Icons.email, _correoController,
                        isEmail: true),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Contraseña', Icons.lock, _contrasenaController,
                        isPassword: true),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Dirección', Icons.location_on, _direccionController),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Teléfono', Icons.phone, _telefonoController),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _registerUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      icon: const Icon(Icons.app_registration),
                      label: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón "¿Ya tienes cuenta?"
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión aquí',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label es obligatorio';
        }
        if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Por favor ingrese un correo electrónico válido';
        }
        if (isPassword && value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  // Lógica de registro con Firebase Authentication y Firestore
void _registerUser() async {
  setState(() {
    _isLoading = true; // Muestra el indicador de carga
  });

  String nombre = _nombreController.text.trim();
  String apellido = _apellidoController.text.trim();
  String correo = _correoController.text.trim();
  String contrasena = _contrasenaController.text.trim();
  String direccion = _direccionController.text.trim();
  String telefono = _telefonoController.text.trim();

  // Asegúrate de limpiar el correo de posibles espacios antes de usarlo
  correo = correo.replaceAll(' ', '');

  // Verificar si el correo contiene '@admin.com' para asignar el rol 'admin'
  String role = correo.contains('@admin.com') ? 'admin' : 'user';

  try {
    // Registrar al usuario en Firebase Authentication
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );

    // Obtener el UID del usuario registrado
    String userId = userCredential.user!.uid;

    // Guardar los datos adicionales del usuario en Firestore
    await _firestore.collection('users').doc(userId).set({
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'direccion': direccion,
      'telefono': telefono,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'role': role,
    });

    // Redirigir a la pantalla correspondiente según el rol
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin_inicio'); // Redirigir al admin
    } else {
      Navigator.pushReplacementNamed(context, '/inicio'); // Redirigir a la pantalla de usuario
    }

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Usuario registrado con éxito."),
        backgroundColor: Colors.green,
      ),
    );
  } on FirebaseAuthException catch (e) {
    // Manejar errores de Firebase Authentication
    String errorMessage;
    if (e.code == 'email-already-in-use') {
      errorMessage = "El correo ya está registrado.";
    } else if (e.code == 'weak-password') {
      errorMessage = "La contraseña es muy débil.";
    } else {
      errorMessage = "Error: ${e.message}";
    }

    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    // Manejar otros errores
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error desconocido: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false; // Oculta el indicador de carga
    });
  }
}
}
