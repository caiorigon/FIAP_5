import 'package:archalyzer/app/views/analysis_list/analysis_list_page.dart';
import 'package:flutter/material.dart';

class PastAnalysesButton extends StatelessWidget {
  const PastAnalysesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        splashColor: Colors.blueGrey[100],
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500, width: .7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 4),
                const Text("Past Analyses"),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisListPage()),
          );
        },
      ),
    );
  }
}
