import 'package:flutter/material.dart';

void main() {
  runApp(LearningPlan());
}

class LearningPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Learning Plan",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Learning Plan"),
        ),
        body: Center(
          child: Text("Implement Everything"),
        ),
      ),
    );
  }
}
