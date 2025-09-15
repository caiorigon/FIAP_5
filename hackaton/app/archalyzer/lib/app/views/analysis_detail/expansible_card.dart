import 'package:flutter/material.dart';

class ExpandableDescriptionCard extends StatefulWidget {
  final String title;
  final String description;
  final int threatsFound;

  const ExpandableDescriptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.threatsFound,
  });

  @override
  State<ExpandableDescriptionCard> createState() =>
      _ExpandableDescriptionCardState();
}

class _ExpandableDescriptionCardState extends State<ExpandableDescriptionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            child: Text(
                              "${widget.threatsFound} threats found",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(widget.description),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: Duration(milliseconds: 200),
                    ),
                  ],
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
