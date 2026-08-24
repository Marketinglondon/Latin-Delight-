// screens/admin_home.dart
// Lista de cestas para el administrador, con filtro por mercado (UK/CO)
// y acceso al formulario de creación/edición.

import 'package:flutter/material.dart';
import '../config.dart';
import '../models/cesta.dart';
import '../services/firestore_service.dart';
import 'cesta_form.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirestoreService _service = FirestoreService();
  String _mercadoFiltro = AppConfig.mercadoUK;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.blanco,
      appBar: AppBar(
        backgroundColor: AppConfig.moradoOscuro,
        title: const Text('Latin Delight — Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'Traducir todos (solo UK)',
            onPressed: _traducirTodos,
          ),
        ],
      ),
      body: Column(
        children: [
          _selectorMercado(),
          Expanded(
            child: StreamBuilder<List<Cesta>>(
              stream: _service.cestasPorMercado(_mercadoFiltro),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cestas = snapshot.data!;
                if (cestas.isEmpty) {
                  return const Center(child: Text('No hay cestas en este mercado todavía.'));
                }
                return ListView.builder(
                  itemCount: cestas.length,
                  itemBuilder: (context, i) => _tarjetaCesta(cestas[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConfig.amarillo,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CestaFormScreen(paisPorDefecto: _mercadoFiltro),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _selectorMercado() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'UK', label: Text('Reino Unido')),
          ButtonSegment(value: 'CO', label: Text('Colombia')),
        ],
        selected: {_mercadoFiltro},
        onSelectionChanged: (s) => setState(() => _mercadoFiltro = s.first),
      ),
    );
  }

  Widget _tarjetaCesta(Cesta cesta) {
    final simbolo = AppConfig.simboloMoneda(cesta.pais);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: cesta.fotos.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(cesta.fotos.first))
            : const CircleAvatar(child: Icon(Icons.card_giftcard)),
        title: Text(cesta.nombre),
        subtitle: Text('${cesta.categoria} · $simbolo${cesta.precioVenta.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CestaFormScreen(cestaExistente: cesta)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmarEliminar(cesta),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Cesta cesta) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar cesta?'),
        content: Text('Se eliminará "${cesta.nombre}" permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              _service.eliminarCesta(cesta.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _traducirTodos() async {
    // Implementación completa: recorrer cestasUkSinTraducir(), traducir
    // con TranslationService y actualizar solo los campos vacíos vía
    // actualizarCampos(). Ver sección 6 de la guía.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Traduciendo cestas del mercado UK...')),
    );
  }
}
