import 'package:flutter/material.dart';
import 'custom_stepper.dart' as custom_stepper;

class LearningStep {
  String title;
  Widget content;

  LearningStep(this.title, this.content);

  custom_stepper.Step getStep() {
    return custom_stepper.Step(
        title: Text(title), content: content, isActive: true);
  }
}
