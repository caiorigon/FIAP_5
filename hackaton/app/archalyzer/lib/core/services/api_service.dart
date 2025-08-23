import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../app/models/analysis_result.dart'; // Your model

class ApiService {
  // Replace with your actual Cloud Run URL
  final _baseUri = dotenv.env['BASE_URI'];
  final authToken = dotenv.env['AUTH_TOKEN'];

  // We provide the AuthService when we create an ApiService
  ApiService();

  Future<AnalysisResult> analyzeDiagram(File imageFile) async {
    final uri = Uri.parse("$_baseUri/analyze-diagram");
    final request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $authToken'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
      ..fields['prompt'] = "Find security issues in this diagram image.";

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // The backend should return the JSON for the analysis
      // and the URL for the analyzed image.
      final responseBody = json.decode(response.body);

      print('Backend Responded');
      return AnalysisResult.fromJson(responseBody);
    } else {
      throw Exception(
        "Failed to analyze diagram. Status code: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}
