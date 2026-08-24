// services/translation_service.dart
// Traducción automática EN -> ES usando la API gratuita MyMemory.
// Solo tiene sentido para cestas del mercado UK (bilingüe); Colombia es
// monolingüe en español y no necesita este servicio.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class TranslationService {
  /// Traduce un texto de inglés a español. Si falla, devuelve el texto
  /// original en inglés para no bloquear el guardado del formulario.
  static Future<String> traducirAEspanol(String textoIngles) async {
    if (textoIngles.trim().isEmpty) return '';

    final uri = Uri.parse(AppConfig.myMemoryEndpoint).replace(queryParameters: {
      'q': textoIngles,
      'langpair': AppConfig.parDeIdiomas,
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return textoIngles;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final traducido = data['responseData']?['translatedText'] as String?;
      return (traducido == null || traducido.trim().isEmpty) ? textoIngles : traducido;
    } catch (_) {
      return textoIngles;
    }
  }
}
