import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Para generar códigos QR
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore


void main() {
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminTicketsPage(), // Página principal de administración
    );
  }
}

class AdminTicketsPage extends StatefulWidget {
  @override
  _AdminTicketsPageState createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  List<Map<String, dynamic>> tickets = [];
  String filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  void _cargarTickets() {
    FirebaseFirestore.instance.collection('tickets').snapshots().listen((snapshot) {
      setState(() {
        tickets = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id; // Asignar el docId al mapa
          return data;
        }).toList();
      });
    });
  }

  // Filtrar tickets por estado
  List<Map<String, dynamic>> _filtrarTickets() {
    if (filtroEstado == 'Todos') return tickets;
    return tickets.where((ticket) => ticket['estado'] == filtroEstado).toList();
  }

  // Función para editar un ticket
  void _editarTicket(int index) {
    final _formKey = GlobalKey<FormState>();
    Map<String, dynamic> ticket = Map.from(tickets[index]);

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
                    Text('Editar Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: ticket['titulo'],
                      decoration: InputDecoration(labelText: 'Título del Problema'),
                      onChanged: (value) => ticket['titulo'] = value,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Estado del Ticket'),
                      value: ticket['estado'],
                      items: ['Pendiente', 'Completado', 'En Proceso'].map((estado) {
                        return DropdownMenuItem(value: estado, child: Text(estado));
                      }).toList(),
                      onChanged: (value) => ticket['estado'] = value!,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await FirebaseFirestore.instance
                              .collection('tickets')
                              .doc(ticket['docId'])
                              .update(ticket);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Guardar Cambios'),
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


  @override
  Widget build(BuildContext context) {
    final filteredTickets = _filtrarTickets();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Tickets'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          DropdownButton<String>(
            dropdownColor: Colors.blue.shade900,
            value: filtroEstado,
            style: TextStyle(color: Colors.white),
            underline: SizedBox(),
            onChanged: (value) {
              setState(() {
                filtroEstado = value!;
              });
            },
            items: ['Todos', 'Pendiente', 'Completado', 'En Proceso'].map((estado) {
              return DropdownMenuItem(value: estado, child: Text(estado));
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTickets.length,
        itemBuilder: (context, index) {
          final ticket = filteredTickets[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              title: Text(ticket['titulo']),
              subtitle: Text('Estado: ${ticket['estado']}'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${ticket['fecha']}'),
                      Text('Funcionando: ${ticket['funcionando']}'),
                      Text('Tipo de Equipo: ${ticket['tipoEquipo']}'),
                      Text('Descripción: ${ticket['descripcion']}'),
                    ],
                  ),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () => _editarTicket(index),
                      child: Text('Editar'),
                    ),
                    TextButton(
                      onPressed: () => _eliminarTicket(index),
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
                _generarQR(ticket['docId']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _generarQR(String docId) {
    return Center(
      child: QrImageView(
        data: docId,
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}
