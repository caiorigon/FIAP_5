import 'dart:io';
import 'package:dio/dio.dart';
import '../../app/models/analysis_result.dart';

class ApiService {
  final Dio dio;

  ApiService({required this.dio});

  Future<AnalysisResult> analyzeDiagram(File imageFile) async {
    try {
      MultipartFile multipartFile = await MultipartFile.fromFile(
        imageFile.path,
      );
      FormData formData = FormData.fromMap({'image': multipartFile});

      final response = await dio.post('/analyze-diagram', data: formData);

      if (response.statusCode == 200) {
        // The backend should return the JSON for the analysis
        // and the URL for the analyzed image.

        var analisys = AnalysisResult.fromJson(response.data);
        analisys.originalImage = imageFile;
        return analisys;
      } else {
        if (response.statusCode == 400) {
          throw Exception(response.data);
        } else {
          throw Exception(
            "Failed to analyze diagram. Status code: ${response.statusCode}, Body: ${response.data}",
          );
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data?['detail'] ?? "Error analyzing the image",
        );
      }
      throw Exception("Error analyzing the image: ${e.message}");
    } catch (e) {
      throw Exception("Error uploading the image: $e");
    }
  }
}
