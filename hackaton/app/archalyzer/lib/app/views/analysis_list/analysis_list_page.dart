import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// TODO: Create the AnalysisDetailScreen file
// import 'analysis_detail_screen.dart'; 

class AnalysisListPage extends StatelessWidget {
  const AnalysisListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final analyses = context.watch<AnalysisController>().analyses;

    return Scaffold(
      appBar: AppBar(title: const Text("Past Analyses")),
      body: analyses.isEmpty
          ? const Center(child: Text("No analyses yet."))
          : ListView.builder(
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                return ListTile(
                  leading: const Icon(Icons.image), // Placeholder for a thumbnail
                  title: Text(analysis.title),
                  subtitle: Text(analysis.createdAt.toLocal().toString()),
                  onTap: () {
                    // TODO: Navigate to the AnalysisDetailScreen
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => AnalysisDetailScreen(analysis: analysis)));
                    print("Tapped on ${analysis.title}");
                  },
                );
              },
            ),
    );
  }
}