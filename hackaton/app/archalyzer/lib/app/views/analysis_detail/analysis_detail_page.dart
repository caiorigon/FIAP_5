// Example: Beautiful HomePage
import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/views/analysis_detail/expandable_component_widget.dart';
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
              subtitle: DateFormat("dd/MM/yyyy - hh:mm").format(analysisController.actualAnalysis!.createdAt),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child:  SingleChildScrollView(
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
                        
                    Text(
                      analysisController.actualAnalysis!.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                        
                    Text(
                      analysisController.actualAnalysis!.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Components with possible security issues:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F5BD5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...analysisController.actualAnalysis!.components!
                            .map(
                              (analizedComponent) =>
                                  ExpandableComponentWidget(
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
