// services/cloudinary_service.dart
// Sube fotos de cestas a Cloudinary (evita el plan de pago de Firebase
// Storage). Usa un "unsigned upload preset" configurado en el dashboard
// de Cloudinary.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class CloudinaryService {
  static Uri get _uploadUrl => Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload');

  /// Sube una imagen y devuelve la URL segura (https) resultante.
  static Future<String> subirImagen(File imagen) async {
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final streamed = await request.send();
    final respuesta = await http.Response.fromStream(streamed);

    if (respuesta.statusCode != 200) {
      throw Exception('Error subiendo imagen a Cloudinary: ${respuesta.body}');
    }

    final data = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  /// Sube varias fotos en orden y devuelve las URLs resultantes.
  static Future<List<String>> subirImagenes(List<File> imagenes) async {
    final urls = <String>[];
    for (final img in imagenes) {
      urls.add(await subirImagen(img));
    }
    return urls;
  }
}
