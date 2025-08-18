import 'dart:convert';

// Helper function to decode JSON easily
AnalysisResult analysisResultFromJson(String str) => AnalysisResult.fromJson(json.decode(str));

class AnalysisResult {
    final String id;
    final String title;
    final String originalImagePath; // Local path to the user's image
    final String analyzedImagePath; // Local path to the image from the backend
    final DateTime createdAt;
    final List<AnalyzedComponent> components;

    AnalysisResult({
        required this.id,
        required this.title,
        required this.originalImagePath,
        required this.analyzedImagePath,
        required this.createdAt,
        required this.components,
    });

    factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        id: json["id"] ?? DateTime.now().toIso8601String(), // Generate an ID if backend doesn't provide one
        title: json["title"],
        originalImagePath: json["originalImagePath"],
        analyzedImagePath: json["analyzedImagePath"],
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : DateTime.now(),
        components: List<AnalyzedComponent>.from(json["components"].map((x) => AnalyzedComponent.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "originalImagePath": originalImagePath,
        "analyzedImagePath": analyzedImagePath,
        "createdAt": createdAt.toIso8601String(),
        "components": List<dynamic>.from(components.map((x) => x.toJson())),
    };
}

class AnalyzedComponent {
    final String componentName;
    final List<String> risks;
    final String securityAnalysis;

    AnalyzedComponent({
        required this.componentName,
        required this.risks,
        required this.securityAnalysis,
    });

    factory AnalyzedComponent.fromJson(Map<String, dynamic> json) => AnalyzedComponent(
        componentName: json["componentName"],
        risks: List<String>.from(json["risks"].map((x) => x)),
        securityAnalysis: json["securityAnalysis"],
    );

    Map<String, dynamic> toJson() => {
        "componentName": componentName,
        "risks": List<dynamic>.from(risks.map((x) => x)),
        "securityAnalysis": securityAnalysis,
    };
}