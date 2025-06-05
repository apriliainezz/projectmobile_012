import 'dart:convert';

import 'package:responsiah/models/movie_model.dart';
import 'package:http/http.dart' as http;

class KdramaService {
  static const url =
      "https://tpm-api-responsi-a-h-872136705893.us-central1.run.app/api/v1/kdrama";

  static Future<Map<String, dynamic>> getKdrama() async {
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addKdrama(Kdrama newKdrama) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newKdrama),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getKdramaById(int id) async {
    final response = await http.get(Uri.parse("$url/$id"));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateKdrama(Kdrama updatedKdrama) async {
    final response = await http.patch(
      Uri.parse("$url/${updatedKdrama.id}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedKdrama),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteKdrama(int id) async {
    final response = await http.delete(Uri.parse("$url/$id"));
    return jsonDecode(response.body);
  }
}
