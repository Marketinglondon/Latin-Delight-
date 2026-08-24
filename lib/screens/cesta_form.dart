// screens/cesta_form.dart
// Formulario para crear o editar una cesta. Incluye selector de mercado
// (pais), que determina si se muestran campos en inglés+español (UK) o
// solo en español (CO), y autotraducción al salir del campo en inglés.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../models/cesta.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';
import '../services/translation_service.dart';

class CestaFormScreen extends StatefulWidget {
  final Cesta? cestaExistente;
  final String? paisPorDefecto;

  const CestaFormScreen({super.key, this.cestaExistente, this.paisPorDefecto});

  @override
  State<CestaFormScreen> createState() => _CestaFormScreenState();
}

class _CestaFormScreenState extends State<CestaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

  late String _pais;
  late TextEditingController _nombreCtrl;
  late TextEditingController _nombreEsCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _descripcionEsCtrl;
  late TextEditingController _contenidoCtrl;
  late TextEditingController _contenidoEsCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _costoCtrl;

  String _categoria = AppConfig.categorias.first;
  String _ocasion = AppConfig.ocasiones.first;
  String _presentacion = AppConfig.presentaciones.first;

  bool _incluyeGlobos = false;
  bool _incluyeFlores = false;
  bool _incluyeAccesorio = false;
  bool _incluyeComida = false;
  bool _incluyeBebida = false;
  bool _enStock = true;

  final List<File> _fotosNuevas = [];
  List<String> _fotosExistentes = [];
  bool _guardando = false;

  bool get _esUK => _pais == AppConfig.mercadoUK;
  bool get _editando => widget.cestaExistente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cestaExistente;
    _pais = c?.pais ?? widget.paisPorDefecto ?? AppConfig.mercadoUK;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _nombreEsCtrl = TextEditingController(text: c?.nombreEs ?? '');
    _descripcionCtrl = TextEditingController(text: c?.descripcion ?? '');
    _descripcionEsCtrl = TextEditingController(text: c?.descripcionEs ?? '');
    _contenidoCtrl = TextEditingController(text: c?.contenido ?? '');
    _contenidoEsCtrl = TextEditingController(text: c?.contenidoEs ?? '');
    _precioCtrl = TextEditingController(text: c?.precioVenta.toString() ?? '');
    _costoCtrl = TextEditingController(text: c?.costoProveedor.toString() ?? '');
    if (c != null) {
      _categoria = c.categoria.isNotEmpty ? c.categoria : _categoria;
      _ocasion = c.ocasion.isNotEmpty ? c.ocasion : _ocasion;
      _presentacion = c.presentacion.isNotEmpty ? c.presentacion : _presentacion;
      _incluyeGlobos = c.incluyeGlobos;
      _incluyeFlores = c.incluyeFlores;
      _incluyeAccesorio = c.incluyeAccesorio;
      _incluyeComida = c.incluyeComida;
      _incluyeBebida = c.incluyeBebida;
      _enStock = c.enStock;
      _fotosExistentes = List.from(c.fotos);
    }
  }

  /// Autotraducción: se llama al perder el foco de un campo en inglés.
  /// Solo aplica si el mercado activo es UK (bilingüe).
  Future<void> _autotraducir(TextEditingController origen, TextEditingController destino) async {
    if (!_esUK) return;
    if (origen.text.trim().isEmpty || destino.text.trim().isNotEmpty) return;
    final traducido = await TranslationService.traducirAEspanol(origen.text);
    destino.text = traducido;
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) setState(() => _fotosNuevas.add(File(img.path)));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      final urlsNuevas = await CloudinaryService.subirImagenes(_fotosNuevas);
      final todasLasFotos = [..._fotosExistentes, ...urlsNuevas];

      final cesta = Cesta(
        id: widget.cestaExistente?.id,
        nombre: _nombreCtrl.text.trim(),
        nombreEs: _esUK ? _nombreEsCtrl.text.trim() : _nombreCtrl.text.trim(),
        categoria: _categoria,
        ocasion: _ocasion,
        presentacion: _presentacion,
        descripcion: _descripcionCtrl.text.trim(),
        descripcionEs: _esUK ? _descripcionEsCtrl.text.trim() : _descripcionCtrl.text.trim(),
        contenido: _contenidoCtrl.text.trim(),
        contenidoEs: _esUK ? _contenidoEsCtrl.text.trim() : _contenidoCtrl.text.trim(),
        incluyeGlobos: _incluyeGlobos,
        incluyeFlores: _incluyeFlores,
        incluyeAccesorio: _incluyeAccesorio,
        incluyeComida: _incluyeComida,
        incluyeBebida: _incluyeBebida,
        pais: _pais,
        costoProveedor: double.tryParse(_costoCtrl.text) ?? 0,
        precioVenta: double.tryParse(_precioCtrl.text) ?? 0,
        enStock: _enStock,
        fotos: todasLasFotos,
        fechaCreacion: widget.cestaExistente?.fechaCreacion,
      );

      if (_editando) {
        await _service.actualizarCesta(cesta.id!, cesta);
      } else {
        await _service.crearCesta(cesta);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final simbolo = AppConfig.simboloMoneda(_pais);

    return Scaffold(
      backgroundColor: AppConfig.blanco,
      appBar: AppBar(
        backgroundColor: AppConfig.moradoOscuro,
        title: Text(_editando ? 'Editar cesta' : 'Nueva cesta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selector de mercado
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'UK', label: Text('Reino Unido (bilingüe)')),
                ButtonSegment(value: 'CO', label: Text('Colombia (solo ES)')),
              ],
              selected: {_pais},
              onSelectionChanged: (s) => setState(() => _pais = s.first),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nombreCtrl,
              decoration: InputDecoration(labelText: _esUK ? 'Nombre (inglés)' : 'Nombre'),
              onEditingComplete: () => _autotraducir(_nombreCtrl, _nombreEsCtrl),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            if (_esUK) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreEsCtrl,
                decoration: const InputDecoration(labelText: 'Nombre (español) — autocompletado, editable'),
              ),
            ],
            const SizedBox(height: 16),

            // Categoría / Ocasión / Presentación
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: AppConfig.categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _ocasion,
              decoration: const InputDecoration(labelText: 'Ocasión'),
              items: AppConfig.ocasiones.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => setState(() => _ocasion = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _presentacion,
              decoration: const InputDecoration(labelText: 'Presentación / Tamaño'),
              items: AppConfig.presentaciones.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _presentacion = v!),
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: InputDecoration(labelText: _esUK ? 'Descripción (inglés)' : 'Descripción'),
              onEditingComplete: () => _autotraducir(_descripcionCtrl, _descripcionEsCtrl),
            ),
            if (_esUK) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionEsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción (español) — autocompletado, editable'),
              ),
            ],
            const SizedBox(height: 16),

            // Contenido (qué incluye la cesta)
            TextFormField(
              controller: _contenidoCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _esUK ? 'Contenido / What\'s included (inglés)' : 'Contenido (qué incluye)',
              ),
              onEditingComplete: () => _autotraducir(_contenidoCtrl, _contenidoEsCtrl),
            ),
            if (_esUK) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _contenidoEsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Contenido (español) — autocompletado, editable'),
              ),
            ],
            const SizedBox(height: 16),

            // Componentes incluidos
            Text('Componentes incluidos', style: Theme.of(context).textTheme.titleMedium),
            CheckboxListTile(
              value: _incluyeGlobos,
              title: const Text('Globos'),
              onChanged: (v) => setState(() => _incluyeGlobos = v!),
            ),
            CheckboxListTile(
              value: _incluyeFlores,
              title: const Text('Flores'),
              onChanged: (v) => setState(() => _incluyeFlores = v!),
            ),
            CheckboxListTile(
              value: _incluyeAccesorio,
              title: const Text('Accesorio / objeto decorativo'),
              onChanged: (v) => setState(() => _incluyeAccesorio = v!),
            ),
            CheckboxListTile(
              value: _incluyeComida,
              title: const Text('Comida'),
              onChanged: (v) => setState(() => _incluyeComida = v!),
            ),
            CheckboxListTile(
              value: _incluyeBebida,
              title: const Text('Bebida'),
              onChanged: (v) => setState(() => _incluyeBebida = v!),
            ),
            SwitchListTile(
              value: _enStock,
              title: const Text('Disponible / en stock'),
              onChanged: (v) => setState(() => _enStock = v),
            ),
            const SizedBox(height: 16),

            // Precios
            TextFormField(
              controller: _precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Precio de venta ($simbolo)'),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Precio inválido' : null,
              // Nota: no auto-guardar en cada tecla — se guarda todo junto
              // al presionar el botón "Guardar" (lección aprendida de Kefify).
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _costoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo proveedor (privado)'),
            ),
            const SizedBox(height: 16),

            // Fotos
            Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                ..._fotosExistentes.map((url) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.red),
                            onPressed: () => setState(() => _fotosExistentes.remove(url)),
                          ),
                        ),
                      ],
                    )),
                ..._fotosNuevas.map((f) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover),
                    )),
                InkWell(
                  onTap: _elegirFoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppConfig.moradoClaro.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.amarillo,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _guardando
                  ? const CircularProgressIndicator()
                  : const Text('Guardar', style: TextStyle(color: Colors.black87, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
