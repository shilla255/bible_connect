import 'package:flutter/material.dart';

class ThemeConstants {
  // Standard Width and Height for Buttons and Text Fields
  static const double standardWidth = 330.0; // Customize the width as needed
  static const double standardHeight = 50.0; // Customize the height as needed

  // Edge Insets for padding or margin
  static const EdgeInsets standardPadding = EdgeInsets.all(8.0);

  // Border Radius for rounded corners
  static const BorderRadius standardBorderRadius = BorderRadius.all(Radius.circular(8.0));

  // BoxDecoration for consistency across buttons and text fields
  static const BoxDecoration standardBoxDecoration = BoxDecoration(
    borderRadius: standardBorderRadius,
    color: Colors.grey, // You can set the color as per your theme
  );
}
