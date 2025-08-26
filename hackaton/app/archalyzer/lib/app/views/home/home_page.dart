import 'package:archalyzer/app/controllers/analysis_controller.dart';
import 'package:archalyzer/app/views/analysis_detail/analysis_detail_page.dart';
import 'package:archalyzer/app/views/home/loading_dialog.dart';
import 'package:archalyzer/app/views/home/main_button.dart';
import 'package:archalyzer/app/views/home/main_title.dart';
import 'package:archalyzer/app/views/home/past_analyses_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnalysisController>();
    return Scaffold(
      appBar: AppBar(
        title: MainTitle(
          title: "Archalyzer",
          subtitle: "Cloud Security Threat Assesment",
        ),
        actions: [PastAnalysesButton()],
      ),
      body: SafeArea(
        child: Consumer<AnalysisController>(
          builder: (context, analysisController, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Analyze your diagram",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Upload or capture a cloud architecture diagram to identify potential STRIDE threats",
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                  SizedBox(height: 36),
                  MainButton(
                    isEnabled: !controller.isLoading,
                    title: "take Picture",
                    description: "Capture a diagram with your camera",
                    icon: Icons.camera_alt_outlined,
                    iconColor: Colors.blue[800],
                    iconBgColor: Colors.blue[50],
                    onPressed: () async {
                      await analysisController.createNewAnalysis(
                        fromCamera: true,
                      );
                      if (controller.actualAnalysis != null &&
                          context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalysisDetailPage(),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  MainButton(
                    isEnabled: !controller.isLoading,
                    title: "Upload picture",
                    description: "Select an image from your device",
                    icon: Icons.upload,
                    iconColor: Colors.green[800],
                    iconBgColor: Colors.green[50],
                    onPressed: () async {
                      LoadingDialog.show(context);
                      await analysisController.createNewAnalysis(
                        fromCamera: false,
                      );
                      if (context.mounted) {
                        LoadingDialog.hide(context);
                        if (controller.actualAnalysis != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnalysisDetailPage(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  if (controller.errorMessage?.isNotEmpty ?? false) ...{
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
