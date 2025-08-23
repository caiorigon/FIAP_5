// Example: Beautiful HomePage
import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/views/analysis_detail/expandable_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalysisDetailPage extends StatelessWidget {
  const AnalysisDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: Text("Details"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<AnalysisController>(
          builder: (context, analysisController, _) {
            return Center(
              child: Card(
                color: Colors.blueGrey[100],
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        const Icon(
                          Icons.security,
                          size: 64,
                          color: Color(0xFF4F5BD5),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          analysisController.actualAnalysis!.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        // Description
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
        ),
      ),
    );
  }
}
