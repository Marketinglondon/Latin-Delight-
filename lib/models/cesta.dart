// models/cesta.dart
// Modelo de datos de una cesta de regalo de Latin Delight Ltd.
// Cada cesta pertenece a UN mercado (pais: 'UK' o 'CO'), con su propio
// contenido, presentación y precio. No es el mismo producto con precio dual.

class Cesta {
  final String? id;

  // Identificación y categoría
  final String nombre;
  final String nombreEs;
  final String? codigo;
  final String categoria; // valor fijo interno (ver AppConfig.categorias)
  final String ocasion;
  final String presentacion; // Pequeña / Mediana / Grande

  // Contenido descriptivo (bilingüe — solo relevante si pais == 'UK')
  final String descripcion;
  final String descripcionEs;
  final String contenido;
  final String contenidoEs;

  // Componentes incluidos (para filtros)
  final bool incluyeGlobos;
  final bool incluyeFlores;
  final bool incluyeAccesorio;
  final bool incluyeComida;
  final bool incluyeBebida;

  // Mercado y precio
  final String pais; // 'UK' o 'CO'
  final double costoProveedor; // privado, solo admin
  final double precioVenta; // en la moneda del país

  // Otros
  final bool enStock;
  final List<String> fotos;
  final String? proveedorNombre;
  final String? proveedorWhatsapp;
  final DateTime? fechaCreacion;

  Cesta({
    this.id,
    required this.nombre,
    this.nombreEs = '',
    this.codigo,
    required this.categoria,
    required this.ocasion,
    required this.presentacion,
    this.descripcion = '',
    this.descripcionEs = '',
    this.contenido = '',
    this.contenidoEs = '',
    this.incluyeGlobos = false,
    this.incluyeFlores = false,
    this.incluyeAccesorio = false,
    this.incluyeComida = false,
    this.incluyeBebida = false,
    required this.pais,
    this.costoProveedor = 0,
    required this.precioVenta,
    this.enStock = true,
    this.fotos = const [],
    this.proveedorNombre,
    this.proveedorWhatsapp,
    this.fechaCreacion,
  });

  /// Texto a mostrar según idioma activo. Si el campo *Es está vacío,
  /// cae de vuelta al valor en inglés (mismo patrón que Kefify).
  static String textoSegunIdioma(String en, String es, String idioma) {
    if (idioma == 'es' && es.trim().isNotEmpty) return es;
    return en;
  }

  String nombreMostrar(String idioma) => textoSegunIdioma(nombre, nombreEs, idioma);
  String descripcionMostrar(String idioma) => textoSegunIdioma(descripcion, descripcionEs, idioma);
  String contenidoMostrar(String idioma) => textoSegunIdioma(contenido, contenidoEs, idioma);

  factory Cesta.fromMap(String id, Map<String, dynamic> map) {
    return Cesta(
      id: id,
      nombre: map['nombre'] ?? '',
      nombreEs: map['nombreEs'] ?? '',
      codigo: map['codigo'],
      categoria: map['categoria'] ?? '',
      ocasion: map['ocasion'] ?? '',
      presentacion: map['presentacion'] ?? '',
      descripcion: map['descripcion'] ?? '',
      descripcionEs: map['descripcionEs'] ?? '',
      contenido: map['contenido'] ?? '',
      contenidoEs: map['contenidoEs'] ?? '',
      incluyeGlobos: map['incluyeGlobos'] ?? false,
      incluyeFlores: map['incluyeFlores'] ?? false,
      incluyeAccesorio: map['incluyeAccesorio'] ?? false,
      incluyeComida: map['incluyeComida'] ?? false,
      incluyeBebida: map['incluyeBebida'] ?? false,
      pais: map['pais'] ?? 'UK',
      costoProveedor: (map['costoProveedor'] ?? 0).toDouble(),
      precioVenta: (map['precioVenta'] ?? 0).toDouble(),
      enStock: map['enStock'] ?? true,
      fotos: List<String>.from(map['fotos'] ?? const []),
      proveedorNombre: map['proveedorNombre'],
      proveedorWhatsapp: map['proveedorWhatsapp'],
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'nombreEs': nombreEs,
      'codigo': codigo,
      'categoria': categoria,
      'ocasion': ocasion,
      'presentacion': presentacion,
      'descripcion': descripcion,
      'descripcionEs': descripcionEs,
      'contenido': contenido,
      'contenidoEs': contenidoEs,
      'incluyeGlobos': incluyeGlobos,
      'incluyeFlores': incluyeFlores,
      'incluyeAccesorio': incluyeAccesorio,
      'incluyeComida': incluyeComida,
      'incluyeBebida': incluyeBebida,
      'pais': pais,
      'costoProveedor': costoProveedor,
      'precioVenta': precioVenta,
      'enStock': enStock,
      'fotos': fotos,
      'proveedorNombre': proveedorNombre,
      'proveedorWhatsapp': proveedorWhatsapp,
      'fechaCreacion': (fechaCreacion ?? DateTime.now()).toIso8601String(),
    };
  }
}
