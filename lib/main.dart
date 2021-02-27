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
  @override
  State<StatefulWidget> createState() => _LearningStepsState();
}

class _LearningStepsState extends State<LearningSteps> {
  int? _currentStep;

  List<LearningStep> steps = [];

  @override
  void initState() {
    super.initState();

    steps = [
      LearningStep("Step 1", Text("Content of step 1")),
      LearningStep("Step 2", Text("Content of step 2")),
      LearningStep("Step 3", Text("Content of step 3"))
    ];
  }

  void stepTapped(int stepNumber) {
    setState(() {
      if (_currentStep != stepNumber)
        _currentStep = stepNumber;
      else
        _currentStep = null;
    });
  }

  void handleStepDelete(int stepNumber) {
    setState(() {
      _showDeleteStepDialog(stepNumber);
    });
  }

  void deleteStep(int stepNumber) {
    setState(() {
      _currentStep = null;
      if (steps.length > stepNumber) steps.removeAt(stepNumber);
    });
  }

  Future<void> _showDeleteStepDialog(int stepNumber) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(steps[stepNumber].title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you really want to delete this step?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                deleteStep(stepNumber);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void stepMoveUp(int stepNumber) {
    if (stepNumber <= 0) return;
    if (stepNumber >= steps.length) return;

    var tmp = steps[stepNumber];

    setState(() {
      steps[stepNumber] = steps[stepNumber - 1];
      steps[stepNumber - 1] = tmp;
      _currentStep = null;
    });
  }

  void stepMoveDown(int stepNumber) {
    if (stepNumber < 0) return;
    if (stepNumber + 1 >= steps.length) return;

    var tmp = steps[stepNumber];

    setState(() {
      steps[stepNumber] = steps[stepNumber + 1];
      steps[stepNumber + 1] = tmp;
      _currentStep = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return custom_stepper.CustomStepper(
      currentStep: _currentStep,
      onStepTapped: stepTapped,
      onStepDelete: handleStepDelete,
      onStepMoveUp: stepMoveUp,
      onStepMoveDown: stepMoveDown,
      steps: steps.map((e) => e.getStep()).toList(),
    );
  }
}
