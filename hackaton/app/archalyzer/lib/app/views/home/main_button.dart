import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const MainButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      splashColor: Colors.blueGrey[100],
      child: Material(
        color:isEnabled? Colors.transparent : Colors.grey[200],
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 1,
          color: isEnabled? Colors.white : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBgColor ?? Colors.grey[50],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(icon, color: iconColor ?? Colors.grey[800]),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
