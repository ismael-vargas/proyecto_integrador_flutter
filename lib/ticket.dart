import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Para generar códigos QR
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Para Firebase Authentication
import 'codigoqr.dart'; // Pantalla para visualizar los QR


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TicketsPage(), // Página principal
    );
  }
}

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

void _cargarTickets() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("No hay usuario autenticado.");
    return;
  }
  FirebaseFirestore.instance
      .collection('tickets')
      .where('uidUsuario', isEqualTo: currentUser.uid)
      .snapshots()
      .listen((snapshot) {
    setState(() {
      tickets = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Asignar el docId al mapa
        return data;
      }).toList();
    });
  });
}

void guardarEnBaseDeDatos(Map<String, dynamic> ticket) async {
  try {
    // Agregar el ticket a Firestore
    DocumentReference docRef = await FirebaseFirestore.instance.collection('tickets').add({
      ...ticket,
      'uidUsuario': FirebaseAuth.instance.currentUser?.uid, // UID del usuario
    });

    // Actualizar el documento para incluir el docId
    await docRef.update({'docId': docRef.id});

    print("Ticket guardado con docId: ${docRef.id}");
  } catch (e) {
    print("Error al guardar el ticket en Firestore: $e");
  }
}


  // Mostrar los códigos QR
  void _mostrarCodigosQR() {
    final List<String> qrData =
        tickets.map((ticket) => ticket['titulo'] as String).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodigoQRScreen(codigosQR: qrData),
      ),
    );
  }

Widget _generarQR(String docId) {
  return Center(
    child: QrImageView(
      data: docId, // Codifica el ID único del documento
      version: QrVersions.auto,
      size: 200.0,
    ),
  );
}

  // Agregar un nuevo ticket
  void _agregarTicket() {
    final _formKey = GlobalKey<FormState>();
    String problema = '';
    String funcionando = 'No';
    String tipoEquipo = 'Refrigerador';
    String tiempoProblema = '';
    String mantenimientoReciente = 'No';
    String descripcion = '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nuevo Ticket',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: '¿Cuál es el problema principal?'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        problema = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: '¿El equipo está funcionando actualmente?'),
                      value: funcionando,
                      items: ['Sí', 'No'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        funcionando = value!;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: '¿Qué tipo de equipo es?'),
                      value: tipoEquipo,
                      items: [
                        'Refrigerador',
                        'Aire Acondicionado',
                        'Otro'
                      ].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        tipoEquipo = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: '¿Hace cuánto tiempo se presentó el problema?'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        tiempoProblema = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText:
                              '¿El equipo ha recibido mantenimiento reciente?'),
                      value: mantenimientoReciente,
                      items: ['Sí', 'No'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        mantenimientoReciente = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Descripción general del problema'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        descripcion = value;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                final nuevoTicket = {
                                  'titulo': problema,
                                  'fecha': DateTime.now()
                                      .toString()
                                      .split(' ')[0],
                                  'estado': 'Pendiente',
                                  'funcionando': funcionando,
                                  'tipoEquipo': tipoEquipo,
                                  'tiempoProblema': tiempoProblema,
                                  'mantenimientoReciente': mantenimientoReciente,
                                  'descripcion': descripcion,
                                };
                                tickets.add(nuevoTicket);
                                guardarEnBaseDeDatos(nuevoTicket);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Guardar Ticket'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para marcar ticket como completado
  void _marcarComoCompletado(int index) {
    setState(() {
      tickets[index]['estado'] = 'Completado';
    });
  }

// Función para confirmar y eliminar un ticket
void _eliminarTicket(int index) async {
  final docId = tickets[index]['docId'];

  // Mostrar el diálogo de confirmación
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este ticket? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancelar
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true), // Confirmar
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  // Si el usuario confirma, se elimina el ticket
  if (confirm == true) {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarTickets(); // Recargar la lista de tickets después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar ticket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  // Función para mostrar ayuda
  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿En qué podemos ayudarte?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Puedes contactarnos a través de los siguientes medios:'),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.blue.shade900),
                  SizedBox(width: 8),
                  Text('+123 456 7890'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.blue.shade900),
                  SizedBox(width: 8),
                  Text('soporte@empresa.com'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tus Tickets'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
child: ExpansionTile(
  title: Text(ticket['titulo']),
  subtitle: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Fecha: ${ticket['fecha']}'),
      Text(
        ticket['estado'],
        style: TextStyle(
          color: ticket['estado'] == 'Completado' ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  children: [
    if (ticket.containsKey('docId')) // Verifica si docId está presente
      _generarQR(ticket['docId']),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¿Funcionando?:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(ticket['funcionando'] ?? 'No especificado'),
                      Text('Tipo de Equipo:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(ticket['tipoEquipo'] ?? 'No especificado'),
                      Text('Tiempo del Problema:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(ticket['tiempoProblema'] ?? 'No especificado'),
                      Text('Mantenimiento Reciente:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(ticket['mantenimientoReciente'] ?? 'No especificado'),
                      Text('Descripción:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(ticket['descripcion'] ?? 'No especificado'),
                    ],
                  ),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () => _marcarComoCompletado(index),
                      child: Text('Marcar como Completado'),
                    ),
                    TextButton(
                      onPressed: () => _eliminarTicket(index),
                      child: Text('Eliminar Ticket'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarCodigosQR,
        child: Icon(Icons.qr_code),
        backgroundColor: Colors.blue.shade900,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.blue.shade900,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              color: Colors.white,
              onPressed: _agregarTicket,
            ),
            IconButton(
              icon: Icon(Icons.help),
              color: Colors.white,
              onPressed: _mostrarAyuda,
            ),
          ],
        ),
      ),
    );
  }
}
