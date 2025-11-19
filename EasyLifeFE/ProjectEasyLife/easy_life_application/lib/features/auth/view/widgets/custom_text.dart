import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  const CustomText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextLiquidFill(
        text: text,
        waveColor: Colors.blueAccent,
        boxBackgroundColor: Pallete.backgroundColor,
        textStyle: TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold,
            fontFamily: 'Horizon'),
        boxHeight: 150.0,
        loadDuration: Duration(seconds: 10),
        waveDuration: Duration(seconds: 2),
        loadUntil: 1,
      ),
    );
  }
  
}
 @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
