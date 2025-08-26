import 'dart:convert';
import 'dart:io';

import 'package:archalyzer/app/models/threat_level.dart';
import 'package:uuid/uuid.dart';

// Helper function to decode JSON easily
AnalysisResult analysisResultFromJson(String str) =>
    AnalysisResult.fromJson(json.decode(str));

class AnalysisResult {
  final String id;
  final String title;
  final String cloud;
  final String description;
  File? originalImage; // Local path to the user's image
  final String? analyzedImage; // Local path to the image from the backend
  final DateTime createdAt;
  final List<AnalyzedComponent>? components;

  AnalysisResult({
    required this.id,
    required this.title,
    required this.cloud,
    required this.description,
    this.originalImage,
    this.analyzedImage,
    required this.createdAt,
    required this.components,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    id: json["id"] ?? const Uuid().v4(),
    title: json["title"],
    cloud: json["cloud"],
    description: json["description"],
    originalImage: json["originalImage"],
    analyzedImage: json["analyzedImage"],
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    components: json["components"] != null
        ? List<AnalyzedComponent>.from(
            json["components"].map(
              (component) => AnalyzedComponent.fromJson(component),
            ),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "originalImage": originalImage,
    "analyzedImage": analyzedImage,
    "createdAt": createdAt.toIso8601String(),
    "components": components != null
        ? List<dynamic>.from(components!.map((x) => x.toJson()))
        : null,
  };
}

class AnalyzedComponent {
  final String componentName;
  final String? description;
  final Threat threat;

  AnalyzedComponent({
    required this.componentName,
    required this.description,
    required this.threat,
  });

  factory AnalyzedComponent.fromJson(Map<String, dynamic> json) =>
      AnalyzedComponent(
        componentName: json["name"],
        description: json["description"],
        threat: Threat.fromJson(json["threat"]),
      );

  Map<String, dynamic> toJson() => {
    "componentName": componentName,
    "description": description,
    "threat": threat.toJson(),
  };
}

class Threat {
  final String? description;
  final ThreatLevel threatLevel;
  final String? possibleMitigation;

  Threat({
    required this.description,
    required this.threatLevel,
    required this.possibleMitigation,
  });

  factory Threat.fromJson(Map<String, dynamic> json) {
    return Threat(
      description: json['description'],
      threatLevel: threatLevelFromString(json['threat_level'] ?? 'Unknown'),
      possibleMitigation: json['possible_mitigation'],
    );
  }

  Map<String, dynamic> toJson() => {
    "description": description,
    "threat_level": threatLevelToString(threatLevel),
    "possible_mitigation": possibleMitigation,
  };
}
