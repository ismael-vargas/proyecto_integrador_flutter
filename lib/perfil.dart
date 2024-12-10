import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';  // Para elegir imágenes
import 'dart:io'; // Para manejar archivos
import 'inicio.dart'; // Asegúrate de que esta sea la ruta correcta a tu pantalla de inicio

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _image; // Para la imagen de perfil
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Función para cargar los datos del perfil desde Firestore
  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Obtener los datos del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Rellenar los campos con la información del usuario
        _nombreController.text = userDoc['nombre'] ?? '';
        _apellidoController.text = userDoc['apellido'] ?? '';
        _correoController.text = userDoc['correo'] ?? '';
        _direccionController.text = userDoc['direccion'] ?? '';
        _telefonoController.text = userDoc['telefono'] ?? '';
        // No necesitamos cargar la foto de perfil porque ya la obtenemos de Firebase Storage si es necesario
      }
    }
  }

  // Función para cargar la imagen desde la galería
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Función para actualizar los datos del perfil en Firestore
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return; // Validar el formulario

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: No estás logueado."),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Subir imagen de perfil a Firebase Storage si hay una nueva imagen
      String? photoUrl = user.photoURL;
      if (_image != null) {
        // Crear referencia a Firebase Storage
        final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');

        // Subir la imagen
        await ref.putFile(_image!);

        // Obtener la URL de la imagen
        photoUrl = await ref.getDownloadURL();
      }

      // Actualizar los datos en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'correo': _correoController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'fotoPerfil': photoUrl,
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Perfil actualizado exitosamente."),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // Manejar errores
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al actualizar el perfil: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40, // Tamaño de la foto de perfil
                      backgroundColor: Colors.grey[300], // Color de fondo si no hay imagen
                      child: Icon(
                        Icons.person, // Ícono por defecto si no hay imagen
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Colors.white), // Ícono de configuración
                        onPressed: () {
                          // Puedes agregar la lógica aquí si necesitas que haga algo al presionar
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ProfileInputField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person,
                hintText: 'Ingresa tu nombre',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              ProfileInputField(
                controller: _apellidoController,
                label: 'Apellido',
                icon: Icons.person,
                hintText: 'Ingresa tu apellido',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  }
                  return null;
                },
              ),
              ProfileInputField(
                controller: _correoController,
                label: 'Correo Electrónico',
                icon: Icons.email,
                hintText: 'Ingresa tu correo',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Por favor ingrese un correo válido';
                  }
                  return null;
                },
              ),
              ProfileInputField(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.location_on,
                hintText: 'Ingresa tu dirección',
              ),
              ProfileInputField(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone,
                hintText: 'Ingresa tu teléfono',
              ),
              ProfileInputField(
                controller: _passwordController,
                label: 'Nueva Contraseña',
                icon: Icons.lock,
                hintText: 'Ingresa tu nueva contraseña',
                isPassword: true,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la pantalla de inicio (InicioScreen.dart)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => InicioScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text('CANCELAR', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900]!),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('GUARDAR', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;

  ProfileInputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hintText,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
