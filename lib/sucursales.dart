import 'package:flutter/material.dart';

class SucursalesScreen extends StatelessWidget {
  final List<Map<String, String>> sucursales = [
    {
      'nombre': 'Sucursal 1',
      'direccion': 'Calle Ejemplo 123, Ciudad',
      'telefono': '(123) 456-7890',
      'horario': 'Lunes a Viernes: 9:00 AM - 6:00 PM',
    },
    {
      'nombre': 'Sucursal 2',
      'direccion': 'Avenida Ficticia 456, Ciudad',
      'telefono': '(321) 654-0987',
      'horario': 'Lunes a Viernes: 9:00 AM - 6:00 PM',
    },
    // Puedes añadir más sucursales aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucursales'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: sucursales.length,
        itemBuilder: (context, index) {
          final sucursal = sucursales[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Colors.blue[900], size: 30),
                      SizedBox(width: 10),
                      Text(
                        sucursal['nombre']!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Dirección: ${sucursal['direccion']}',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Teléfono: ${sucursal['telefono']}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Horario: ${sucursal['horario']}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(color: Colors.grey, thickness: 1),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Aquí puedes agregar la acción para mostrar más detalles
                    },
                    child: Text(
                      'Ver más detalles',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
