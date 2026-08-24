// config.dart
// Configuración central de Latin Delight Ltd.
// Ajusta aquí los valores reales antes de compilar / publicar.

import 'package:flutter/material.dart';

class AppConfig {
  // ---------------------------------------------------------------------
  // MARCA
  // ---------------------------------------------------------------------
  static const String nombreNegocio = 'Latin Delight Ltd.';
  static const String eslogan = "Capture a smile on your love one's face";
  static const String eslogenEs = 'Captura una sonrisa en el rostro de tu ser querido';

  // ---------------------------------------------------------------------
  // COLORES (extraídos del logo)
  // ---------------------------------------------------------------------
  static const Color moradoOscuro = Color(0xFF7A3E8C); // tapa de la caja
  static const Color moradoClaro  = Color(0xFFD9A8E5); // cuerpo + anillo
  static const Color amarillo     = Color(0xFFF4CE1E); // moño
  static const Color turquesa     = Color(0xFF1E96AC); // texto / eslogan
  static const Color blanco       = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // MERCADOS — dos inventarios independientes con distinto contenido,
  // presentaciones y moneda. NO es el mismo producto con precio dual:
  // cada cesta pertenece a un solo país.
  // ---------------------------------------------------------------------
  static const String mercadoUK = 'UK';
  static const String mercadoCO = 'CO';

  // Idiomas habilitados por mercado
  static const Map<String, List<String>> idiomasPorMercado = {
    'UK': ['en', 'es'], // bilingüe
    'CO': ['es'],       // solo español, sin selector de idioma
  };

  static const Map<String, String> idiomaPorDefecto = {
    'UK': 'en',
    'CO': 'es',
  };

  // Símbolo y código de moneda por mercado
  static const Map<String, String> simboloMonedaPorMercado = {
    'UK': '£',
    'CO': '\$',
  };
  static const Map<String, String> codigoMonedaPorMercado = {
    'UK': 'GBP',
    'CO': 'COP',
  };

  // ---------------------------------------------------------------------
  // CONTACTO — un número de WhatsApp por mercado
  // ---------------------------------------------------------------------
  static const Map<String, String> numeroWhatsappPorMercado = {
    'UK': '447446830987',
    'CO': '573226082281',
  };

  // ---------------------------------------------------------------------
  // CLOUDINARY
  // ---------------------------------------------------------------------
  static const String cloudinaryCloudName = 'TU_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'TU_UPLOAD_PRESET';

  // ---------------------------------------------------------------------
  // FIREBASE / FIRESTORE
  // ---------------------------------------------------------------------
  static const String firestoreProjectId = 'TU_PROJECT_ID';
  static const String firestoreCollection = 'cestas';
  // Cada documento en "cestas" incluye el campo `pais` ('UK' o 'CO')
  // para saber a qué inventario/catálogo pertenece.

  // ---------------------------------------------------------------------
  // CATEGORÍAS (valor fijo interno — deben coincidir EXACTAMENTE,
  // mayúsculas y espacios incluidos, entre la app y el catálogo web).
  // ---------------------------------------------------------------------
  static const List<String> categorias = [
    'Desayuno',
    'Snacks',
    'Comidas',
    'Bebidas',
    'Cestas con globos',
    'Cestas con flores',
    'Accesorios',
  ];

  // ---------------------------------------------------------------------
  // OCASIONES
  // ---------------------------------------------------------------------
  static const List<String> ocasiones = [
    'Cumpleaños',
    'Aniversario',
    'Amor y amistad',
    'Get well soon',
    'Nuevo bebé',
    'Graduación',
    'Sin ocasión especial',
  ];

  // ---------------------------------------------------------------------
  // TAMAÑOS DE CESTA
  // ---------------------------------------------------------------------
  static const List<String> presentaciones = [
    'Pequeña',
    'Mediana',
    'Grande',
  ];

  // ---------------------------------------------------------------------
  // TRADUCCIÓN AUTOMÁTICA (MyMemory API — gratuita)
  // Solo se usa para cestas con pais='UK'; Colombia es monolingüe.
  // ---------------------------------------------------------------------
  static const String myMemoryEndpoint = 'https://api.mymemory.translated.net/get';
  static const String parDeIdiomas = 'en|es';

  // ---------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------

  /// Determina el mercado a partir del código de país detectado por ipapi.co
  static String mercadoDesdeCodigoPais(String countryCode) {
    return countryCode.toUpperCase() == 'CO' ? mercadoCO : mercadoUK;
  }

  static String simboloMoneda(String pais) =>
      simboloMonedaPorMercado[pais] ?? simboloMonedaPorMercado[mercadoUK]!;

  static String numeroWhatsapp(String pais) =>
      numeroWhatsappPorMercado[pais] ?? numeroWhatsappPorMercado[mercadoUK]!;

  static bool mercadoEsBilingue(String pais) =>
      (idiomasPorMercado[pais] ?? const ['es']).length > 1;
}
