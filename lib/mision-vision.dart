import 'package:flutter/material.dart';

class MisionVisionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Misión y Visión'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        // Hace que el contenido sea desplazable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineamos el texto a la izquierda
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.blue[900], size: 30), // Ícono decorativo
                  SizedBox(width: 10),
                  Text(
                    'Nuestra Misión:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Mejorar la experiencia de nuestros clientes con servicios de climatización diseñados para reducir sus costos de operaciones. '
                'Transformando sus espacios en ambientes confortables y sostenibles ofreciendo soluciones innovadoras y eficientes, '
                'a través de un servicio personalizado y de alta calidad.',
                textAlign: TextAlign.justify, // Texto justificado
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 127, 141, 153)),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.blue[900], size: 30), // Ícono decorativo
                  SizedBox(width: 10),
                  Text(
                    'Nuestra Visión:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Ser reconocidos como líderes en servicio de climatización en la ciudad de Quito, optimizando su consumo energético. '
                'Convertirnos en la empresa más diversificada, ofreciendo una amplia gama de servicios complementarios, respaldados '
                'por un equipo técnico altamente capacitado y comprometido con la satisfacción al cliente.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 127, 141, 153)),
              ),
              SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.blue[900], size: 40),
                    SizedBox(height: 10),
                    Text(
                      '¡Innovamos para tu confort y sostenibilidad!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 12, 13, 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
