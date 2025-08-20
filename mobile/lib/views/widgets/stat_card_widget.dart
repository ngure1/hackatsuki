import 'package:flutter/material.dart';

class StatCardWidget extends StatelessWidget{
  const StatCardWidget({super.key, required this.stat, required this.description});
 
  final String stat;
  final String description;
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(stat),
        SizedBox(height: 10.0),
        Text(description),
      ])
    );
  }
}
