import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/views/analysis_detail/analysis_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class AnalysisListPage extends StatelessWidget {
  const AnalysisListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final analyses = context.watch<AnalysisController>().analyses;

    return Scaffold(
      appBar: AppBar(title: const Text("Past Analyses"), centerTitle: true),
      body: analyses.isEmpty
          ? const Center(child: Text("No analyses yet."))
          : Consumer<AnalysisController>(
              builder: (context, analysisController, _) {
                return ListView.builder(
                  itemCount: analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = analyses[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.image,
                      ), // Placeholder for a thumbnail
                      title: Text(analysis.title),
                      subtitle: Text(
                        DateFormat(
                          "dd/MM/yyyy - hh:mm:ss",
                        ).format(analysis.createdAt.toLocal()),
                      ),
                      onTap: () {
                        analysisController.actualAnalysis = analysis;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalysisDetailPage(),
                          ),
                        );
                        print("Tapped on ${analysis.title}");
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
