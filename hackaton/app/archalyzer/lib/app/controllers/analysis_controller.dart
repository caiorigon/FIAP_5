import 'dart:io';

import 'package:archalyzer/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/api_service.dart';
import '../models/analysis_result.dart';

class AnalysisController with ChangeNotifier {
  // The controller now owns the services
  final ApiService _apiService = locator<ApiService>();
  final ImagePicker _imagePicker = ImagePicker();

  final List<AnalysisResult> _analyses = [];
  AnalysisResult? actualAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  List<AnalysisResult> get analyses => _analyses;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnalysisController();

  // --- Core Function ---
  Future<void> createNewAnalysis({bool fromCamera = false}) async {
    _isLoading = true;
    _errorMessage = null;
    actualAnalysis = null;
    notifyListeners();

    try {
      // 1. Pick Image
      final imageFile = await _pickImage(fromCamera: fromCamera);
      if (imageFile == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final newAnalysis = await _apiService.analyzeDiagram(imageFile);

      _analyses.insert(0, newAnalysis);
      actualAnalysis = newAnalysis;

      // TODO: Add logic here to save the result to the device's storage.
    } catch (e) {
      _errorMessage = "An error occurred: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Helper Method ---
  Future<File?> _pickImage({required bool fromCamera}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _imagePicker.pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
