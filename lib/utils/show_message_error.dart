import 'package:flutter/material.dart';

void showErrorMessage(context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: 550,
      content: Center(
        child: Text(
          error,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Color(0xFFE74C3C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      duration: Duration(seconds: 2),
    ),
  );
}