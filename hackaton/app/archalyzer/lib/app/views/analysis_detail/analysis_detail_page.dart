import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/models/threat_level.dart';
import 'package:archalyzer/app/views/analysis_detail/expandable_component_widget.dart';
import 'package:archalyzer/app/views/analysis_detail/expansible_card.dart';
import 'package:archalyzer/app/views/home/loading_dialog.dart';
import 'package:archalyzer/app/views/home/main_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalysisDetailPage extends StatelessWidget {
  const AnalysisDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisController>(
      builder: (context, analysisController, _) {
        return Scaffold(
          appBar: AppBar(
            title: MainTitle(
              title: "Analysis Details",
              subtitle: DateFormat(
                "dd/MM/yyyy - HH:mm",
              ).format(analysisController.actualAnalysis!.createdAt),
            ),
            actions: [
              InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.share_rounded, size: 30),
                ),
                onTap: () async {
                  // Show loading indicator
                  LoadingDialog.show(
                    context,
                    title: "Generating PDF",
                    description: "Please wait while the file is generated...",
                  );

                  try {
                    await analysisController.generateAndSharePdf();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to share PDF: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
              SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (analysisController.actualAnalysis?.originalImage !=
                        null)
                      Image(
                        image: FileImage(
                          analysisController.actualAnalysis!.originalImage!,
                        ),
                      ),
                    if (analysisController.actualAnalysis?.originalImage ==
                        null)
                      const Icon(
                        Icons.security,
                        size: 64,
                        color: Color(0xFF4F5BD5),
                      ),
                    const SizedBox(height: 24),

                    ExpandableDescriptionCard(
                      title: analysisController.actualAnalysis!.title,
                      description:
                          analysisController.actualAnalysis!.description,
                      threatsFound: analysisController
                          .actualAnalysis!
                          .components!
                          .where(
                            (component) =>
                                hasThreat(component.threat.threatLevel),
                          )
                          .length,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Identified Components',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...analysisController.actualAnalysis!.components!.map(
                          (analizedComponent) => ExpandableComponentWidget(
                            component: analizedComponent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
