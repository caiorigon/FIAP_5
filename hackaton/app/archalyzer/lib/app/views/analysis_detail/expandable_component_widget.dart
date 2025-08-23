import 'package:archalyzer/app/models/threat_level.dart';

import '../../models/analysis_result.dart';
import 'package:flutter/material.dart';

class ExpandableComponentWidget extends StatefulWidget {
  final AnalyzedComponent component;
  const ExpandableComponentWidget({super.key, required this.component});

  @override
  State<ExpandableComponentWidget> createState() =>
      _ExpandableComponentWidgetState();
}

MaterialColor getThreatLevelColor(ThreatLevel level) {
  switch (level) {
    case ThreatLevel.low:
      return Colors.green;
    case ThreatLevel.medium:
      return Colors.orange;
    case ThreatLevel.high:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class _ExpandableComponentWidgetState extends State<ExpandableComponentWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _expanded ? 2 : 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.warning,
              color: getThreatLevelColor(widget.component.threat.threatLevel),
              size: 24,
            ),
            title: Text(
              widget.component.componentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[700],
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Threat Level: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: threatLevelToString(
                            widget.component.threat.threatLevel,
                          ),
                          style: TextStyle(
                            color: getThreatLevelColor(
                              widget.component.threat.threatLevel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Possible Threat: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: widget.component.threat.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Mitigation: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: widget.component.threat.possibleMitigation,
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
