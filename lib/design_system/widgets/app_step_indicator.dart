import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class AppStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const AppStepIndicator({
    super.key,
    this.totalSteps = 3,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.0 : 0.0),
            height: 3.0,
            decoration: BoxDecoration(
              color: isActive ? colors.actionPrimary : colors.borderDefault,
              borderRadius: BorderRadius.circular(2.0),
            ),

          ),
        );
      }),
    );
  }
}
