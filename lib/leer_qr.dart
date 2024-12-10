import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Paquete para leer QR

class LeerQRScreen extends StatefulWidget {
  @override
  _LeerQRScreenState createState() => _LeerQRScreenState();
}

class _LeerQRScreenState extends State<LeerQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // Corrección en el uso de GlobalKey
  QRViewController? controller;
  String? qrText = "Escanea un código QR"; // Texto inicial

  // Función para manejar la lectura del QR
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code; // Muestra el texto del QR escaneado
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose(); // Liberar recursos del QRViewController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leer Código QR'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey, // Usar GlobalKey aquí
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    qrText ?? "Escanea un código QR",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Datos del QR: $qrText',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
