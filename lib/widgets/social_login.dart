import 'package:flutter/material.dart';

Container socialloginmethod(String asset, String text,Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), // Border color
      borderRadius: BorderRadius.circular(10), // Rounded corners
      color: Colors.white, // Background color
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(asset, width: 24, height: 24), // Replace with your Google icon asset
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}