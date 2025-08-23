import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _customDialog(context),
        );
      },
    );
  }

  static hide(BuildContext context) {
    Navigator.pop(context);
  }

  static _customDialog(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    color: Colors.blue[800],
                    strokeWidth: 2,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Text(
                "Analyzing Diagram",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Identifying threats and vulnerabilities...",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
