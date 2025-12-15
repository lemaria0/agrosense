import 'package:flutter/material.dart';

void showOkMessage(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: 550,
      content: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Color(0xFF4EC835),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 2),
    ),
  );
}