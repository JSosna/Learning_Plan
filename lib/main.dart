import 'package:flutter/material.dart';
import 'package:learning_plan/learningStep.dart';
import 'package:flutter/rendering.dart';

import 'custom_stepper.dart' as custom_stepper;

void main() {
  runApp(LearningPlan());
}

class LearningPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Learning Plan",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Learning Plan"),
        ),
        body: LearningSteps(),
      ),
    );
  }
}

class LearningSteps extends StatefulWidget {
  // test
  final steps = [
    LearningStep("Step 1", "Content of step 1"),
    LearningStep("Step 2", "Content of step 2"),
    LearningStep("Step 3", "Content of step 3")
  ];

  @override
  State<StatefulWidget> createState() => _LearningStepsState();
}

class _LearningStepsState extends State<LearningSteps> {
  int? _currentStep;

  void stepTapped(int stepNumber) {
    setState(() {
      if (_currentStep != stepNumber)
        _currentStep = stepNumber;
      else
        _currentStep = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return custom_stepper.CustomStepper(
      currentStep: _currentStep,
      onStepTapped: stepTapped,
      steps: widget.steps.map((e) => e.getStep()).toList(),
    );
  }
}
