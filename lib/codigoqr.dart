import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importación necesaria para manejar QR

class CodigoQRScreen extends StatelessWidget {
  final List<String> codigosQR;

  CodigoQRScreen({required this.codigosQR});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Códigos QR de Tickets'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        itemCount: codigosQR.length,
        itemBuilder: (context, index) {
          // El título será "Completado" o "Pendiente"
          String estado = codigosQR[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(estado),
              subtitle: _generarQR(estado),
            ),
          );
        },
      ),
    );
  }

  // Función para generar el QR con base en el estado
  Widget _generarQR(String data) {
    // Generamos el código QR con el estado
    return Center(
      child: QrImageView(
        data: data,  // El QR mostrará "Completado" o "Pendiente"
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}
