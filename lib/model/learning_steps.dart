import 'package:flutter/material.dart';

import 'learning_step.dart';

class LearningSteps extends ChangeNotifier {
  int? currentStepIndex;

  List<LearningStep> steps = [
    LearningStep("Step 1", Text("Content of step 1")),
    LearningStep("Step 2", Text("Content of step 2")),
    LearningStep("Step 3", Text("Content of step 3"))
  ];

  void addStep(LearningStep newStep) {
    // TODO: complete this method
    notifyListeners();
  }

  void setCurrentStep(int stepNumber) {
    if (currentStepIndex != stepNumber)
      currentStepIndex = stepNumber;
    else
      currentStepIndex = null;

    notifyListeners();
  }

  void deleteStep(int stepNumber) {
    currentStepIndex = null;
    if (steps.length > stepNumber) steps.removeAt(stepNumber);

    notifyListeners();
  }

  void stepMoveUp(int stepNumber) {
    if (stepNumber <= 0) return;
    if (stepNumber >= steps.length) return;

    var tmp = steps[stepNumber];

    steps[stepNumber] = steps[stepNumber - 1];
    steps[stepNumber - 1] = tmp;
    currentStepIndex = null;

    notifyListeners();
  }

  void stepMoveDown(int stepNumber) {
    if (stepNumber < 0) return;
    if (stepNumber + 1 >= steps.length) return;

    var tmp = steps[stepNumber];

    steps[stepNumber] = steps[stepNumber + 1];
    steps[stepNumber + 1] = tmp;
    currentStepIndex = null;

    notifyListeners();
  }

  void swapSteps(int oldStep, int newStep) {
    if (oldStep >= steps.length || newStep >= steps.length) return;
    if (oldStep == newStep) return;

    var tmp = steps[oldStep];

    steps[oldStep] = steps[newStep];
    steps[newStep] = tmp;
    currentStepIndex = null;

    notifyListeners();
  }
}
