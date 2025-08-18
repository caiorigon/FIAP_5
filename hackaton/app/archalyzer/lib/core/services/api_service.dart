import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../app/models/analysis_result.dart'; // Your model
import 'auth_service.dart'; // Your existing AuthService

class ApiService {
  final AuthService _authService;
  // Replace with your actual Cloud Run URL
  final String _baseUrl = "https://archalyzer-backend-xyz-uc.a.run.app"; 

  // We provide the AuthService when we create an ApiService
  ApiService({required AuthService authService}) : _authService = authService;

  Future<AnalysisResult> analyzeDiagram(File imageFile) async {
    // 1. Get the authentication token
    final token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception("Authentication failed. Could not get token.");
    }

    // 2. Create the multipart request
    final uri = Uri.parse("$_baseUrl/analyse-diagram");
    final request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // This 'file' key must match your FastAPI backend
          imageFile.path,
        ),
      );

    // 3. Send the request and handle the response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // The backend should return the JSON for the analysis
      // and the URL for the analyzed image.
      final responseBody = json.decode(response.body);
      
      // TODO: Here you would download the analyzed image from the URL
      // provided in the response and save it locally.
      // For now, we'll just use the original image path as a placeholder.
      return AnalysisResult(
        id: responseBody['id'] ?? DateTime.now().toIso8601String(),
        title: responseBody['title'],
        originalImagePath: imageFile.path,
        analyzedImagePath: imageFile.path, // Placeholder
        createdAt: DateTime.now(),
        components: (responseBody['components'] as List)
            .map((compJson) => AnalyzedComponent(
                  componentName: compJson['component_name'],
                  risks: List<String>.from(compJson['risks']),
                  securityAnalysis: compJson['security_analysis'],
                ))
            .toList(),
      );
    } else {
      throw Exception("Failed to analyze diagram. Status code: ${response.statusCode}, Body: ${response.body}");
    }
  }
}