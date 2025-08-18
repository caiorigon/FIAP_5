import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/views/analysis_list/analysis_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the controller's state
    final controller = context.watch<AnalysisController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Archalyzer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisListPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If it's loading, show a spinner, otherwise show the buttons
            if (controller.isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Diagram"),
                    onPressed: () {
                      // Use context.read inside callbacks to call functions
                      context.read<AnalysisController>().createNewAnalysis(fromCamera: false);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Picture"),
                    onPressed: () {
                      context.read<AnalysisController>().createNewAnalysis(fromCamera: true);
                    },
                  ),
                ],
              ),
            
            // If there's an error, display it
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}