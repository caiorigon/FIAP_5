import 'dart:io';
import 'package:archalyzer/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/api_service.dart';
import '../models/analysis_result.dart';
import '../models/threat_level.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

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

  // --- Helper method to get threat level string ---
  String _getThreatLevelString(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.none:
        return 'None';
      case ThreatLevel.low:
        return 'Low';
      case ThreatLevel.medium:
        return 'Medium';
      case ThreatLevel.high:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  // --- Helper method to get threat level color for PDF ---
  PdfColor _getThreatLevelPdfColor(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.none:
        return PdfColors.green;
      case ThreatLevel.low:
        return PdfColors.blue;
      case ThreatLevel.medium:
        return PdfColors.orange;
      case ThreatLevel.high:
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  // --- Generate and Share PDF ---
  Future<void> generateAndSharePdf() async {
    if (actualAnalysis == null) return;

    try {
      final pdf = pw.Document();

      // Load image if exists
      pw.ImageProvider? diagramImage;
      if (actualAnalysis!.originalImage != null) {
        final imageBytes = await actualAnalysis!.originalImage!.readAsBytes();
        diagramImage = pw.MemoryImage(imageBytes);
      }

      // Count threats
      final threatsFound =
          actualAnalysis!.components
              ?.where((component) => hasThreat(component.threat.threatLevel))
              .length ??
          0;

      // Add main page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Analysis Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${DateFormat("dd/MM/yyyy - HH:mm").format(actualAnalysis!.createdAt)}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Divider(height: 20),
                ],
              ),

              // Diagram image (if exists)
              if (diagramImage != null) ...[
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    diagramImage,
                    height: 200,
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Analysis Overview
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      actualAnalysis!.title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      actualAnalysis!.description,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: threatsFound > 0
                            ? PdfColors.red50
                            : PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'Threats Found: $threatsFound',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: threatsFound > 0
                              ? PdfColors.red
                              : PdfColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Components Section
              pw.Text(
                'Identified Components',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Components list
              ...actualAnalysis!.components?.map((component) {
                    final threatLevel = component.threat.threatLevel;
                    final hasThreats = hasThreat(threatLevel);

                    return pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 10),
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: _getThreatLevelPdfColor(
                            threatLevel,
                          ).shade(0.3),
                          width: 1,
                        ),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Component header
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  component.componentName,
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  _getThreatLevelString(threatLevel),
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: _getThreatLevelPdfColor(threatLevel),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 6),

                          // Component description
                          pw.Text(
                            component.description ?? "Description not provided",
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey700,
                            ),
                          ),

                          // Threat details (if exists)
                          if (hasThreats) ...[
                            pw.SizedBox(height: 10),
                            pw.Divider(height: 1, color: PdfColors.grey300),
                            pw.SizedBox(height: 10),

                            if (component.threat.description != null) ...[
                              pw.Text(
                                'Threat Description:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                component.threat.description!,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],

                            if (component.threat.possibleMitigation !=
                                null) ...[
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'Possible Mitigation:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                component.threat.possibleMitigation!,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    );
                  }).toList() ??
                  [],

              // Footer
              pw.SizedBox(height: 30),
              pw.Divider(height: 1),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated by Archalyzer',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'analysis_report_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Analysis Report - ${actualAnalysis!.title}',
        text:
            'Analysis report generated on ${DateFormat("dd/MM/yyyy - HH:mm").format(actualAnalysis!.createdAt)}',
      );
    } catch (e) {
      _errorMessage = "Failed to generate PDF: ${e.toString()}";
      notifyListeners();
    }
  }
}
