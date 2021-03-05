import 'package:flutter/material.dart';
import 'package:learning_plan/model/learning_step.dart';
import 'package:flutter/rendering.dart';
import 'package:learning_plan/model/learning_steps.dart';
import 'package:provider/provider.dart';

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
        body: ChangeNotifierProvider<LearningSteps>(
            create: (context) => LearningSteps(), child: LearningPlanContent()),
      ),
    );
  }
}

class LearningPlanContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var learningSteps = Provider.of<LearningSteps>(context);

    return custom_stepper.CustomStepper(
      currentStep: learningSteps.currentStepIndex,
      onStepTapped: (tappedStepIndex) =>
          learningSteps.setCurrentStep(tappedStepIndex),
      onStepDelete: (stepToDeleteIndex) {
        _showDeleteStepDialog(context, stepToDeleteIndex, learningSteps);
      },
      onStepMoveUp: (stepIndex) => learningSteps.stepMoveUp(stepIndex),
      onStepMoveDown: (stepIndex) => learningSteps.stepMoveDown(stepIndex),
      onStepDropAccepted: (oldStepIndex, newStepIndex) =>
          learningSteps.swapSteps(oldStepIndex, newStepIndex),
      steps: learningSteps.steps.map((e) => e.getStep()).toList(),
    );
  }
}

Future<void> _showDeleteStepDialog(BuildContext context, int stepToDeleteIndex,
    LearningSteps learningSteps) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(learningSteps.steps[stepToDeleteIndex].title),
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
              learningSteps.deleteStep(stepToDeleteIndex);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
