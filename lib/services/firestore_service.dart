// services/firestore_service.dart
// CRUD de cestas contra Firestore, usando el SDK oficial de Flutter
// (cloud_firestore). El catálogo web (index.html / admin.html) usa en
// cambio la API REST pública de Firestore — ver sección 9 de la guía.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../config.dart';
import '../models/cesta.dart';

class FirestoreService {
  final CollectionReference _coleccion =
      FirebaseFirestore.instance.collection(AppConfig.firestoreCollection);

  /// Stream de todas las cestas de un mercado específico ('UK' o 'CO').
  Stream<List<Cesta>> cestasPorMercado(String pais) {
    return _coleccion
        .where('pais', isEqualTo: pais)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Cesta.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream de TODAS las cestas (para el panel admin, con filtro opcional).
  Stream<List<Cesta>> todasLasCestas() {
    return _coleccion
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Cesta.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<String> crearCesta(Cesta cesta) async {
    final doc = await _coleccion.add(cesta.toMap());
    return doc.id;
  }

  Future<void> actualizarCesta(String id, Cesta cesta) async {
    await _coleccion.doc(id).update(cesta.toMap());
  }

  /// Actualiza solo los campos indicados (usado por "Traducir todos").
  Future<void> actualizarCampos(String id, Map<String, dynamic> campos) async {
    await _coleccion.doc(id).update(campos);
  }

  Future<void> eliminarCesta(String id) async {
    await _coleccion.doc(id).delete();
  }

  /// Cestas con pais='UK' que tienen texto en inglés pero no en español,
  /// usado por el botón "Traducir todos" (solo aplica al mercado UK).
  Future<List<Cesta>> cestasUkSinTraducir() async {
    final snap = await _coleccion.where('pais', isEqualTo: AppConfig.mercadoUK).get();
    return snap.docs
        .map((d) => Cesta.fromMap(d.id, d.data() as Map<String, dynamic>))
        .where((c) =>
            (c.nombre.isNotEmpty && c.nombreEs.isEmpty) ||
            (c.descripcion.isNotEmpty && c.descripcionEs.isEmpty) ||
            (c.contenido.isNotEmpty && c.contenidoEs.isEmpty))
        .toList();
  }
}
