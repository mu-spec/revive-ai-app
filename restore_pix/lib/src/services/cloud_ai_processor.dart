import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class CloudAiProcessor {
  /// Calls a generic REST API Endpoint (e.g., Stability AI / Fal.ai / Replicate)
  /// Using standard Dart HttpClient for ultimate dependency stability.
  static Future<Uint8List> callCloudApi({
    required Uint8List imageBytes,
    required String endpointUrl,
    required String apiKey,
    required Map<String, dynamic> parameters,
  }) async {
    if (apiKey.isEmpty || apiKey == 'DEMO_KEY') {
      throw Exception('API Key is not configured. Please add your paid API Key in Settings or switch to the 100% Free On-Device AI Engine.');
    }

    final httpClient = HttpClient();
    try {
      final request = await httpClient.postUrl(Uri.parse(endpointUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.headers.set('Accept', 'image/jpeg');

      final base64Image = base64Encode(imageBytes);
      final body = jsonEncode({
        'image': base64Image,
        ...parameters,
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        return bytes;
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        throw Exception('Cloud AI Error (${response.statusCode}): $responseBody');
      }
    } finally {
      httpClient.close();
    }
  }
}
