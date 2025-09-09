import 'package:archalyzer/app/models/threat_level.dart';
import '../../models/analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpandableComponentWidget extends StatefulWidget {
  final AnalyzedComponent component;
  const ExpandableComponentWidget({super.key, required this.component});

  @override
  State<ExpandableComponentWidget> createState() =>
      _ExpandableComponentWidgetState();
}

MaterialColor getThreatLevelColor(ThreatLevel level) {
  switch (level) {
    case ThreatLevel.none:
      return Colors.green;
    case ThreatLevel.low:
      return Colors.blue;
    case ThreatLevel.medium:
      return Colors.orange;
    case ThreatLevel.high:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getThreatLevelIcon(ThreatLevel level) {
  switch (level) {
    case ThreatLevel.none:
      return FontAwesomeIcons.check;
    case ThreatLevel.low:
      return FontAwesomeIcons.circleCheck;
    case ThreatLevel.medium:
      return FontAwesomeIcons.circleInfo;
    case ThreatLevel.high:
      return FontAwesomeIcons.triangleExclamation;
    default:
      return FontAwesomeIcons.circleQuestion;
  }
}

class _ExpandableComponentWidgetState extends State<ExpandableComponentWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: hasThreat(widget.component.threat.threatLevel)
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: getThreatLevelColor(
                        widget.component.threat.threatLevel,
                      ).shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: .5,
                        color: getThreatLevelColor(
                          widget.component.threat.threatLevel,
                        ).shade300,
                      ),
                    ),
                    child: Icon(
                      color: getThreatLevelColor(
                        widget.component.threat.threatLevel,
                      ),
                      getThreatLevelIcon(widget.component.threat.threatLevel),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.component.componentName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.component.description ??
                              "Description not provided",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: getThreatLevelColor(
                        widget.component.threat.threatLevel,
                      ).shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: .5,
                        color: getThreatLevelColor(
                          widget.component.threat.threatLevel,
                        ).shade300,
                      ),
                    ),
                    child: Text(
                      threatLevelToString(widget.component.threat.threatLevel),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: getThreatLevelColor(
                          widget.component.threat.threatLevel,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  if (hasThreat(widget.component.threat.threatLevel))
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 30,
                    ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12),
                    Divider(height: .5),
                    SizedBox(height: 8),
                    Text(
                      "Threat Description",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.component.threat.description ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Possible Mitigation",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.component.threat.possibleMitigation ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
