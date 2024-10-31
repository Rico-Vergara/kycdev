import 'package:flutter/material.dart';

class NumberStepper extends StatelessWidget {
  final double? width;
  final int? totalSteps;
  final int? curStep;
  final Color? stepCompleteColor;
  final Color? currentStepColor;
  final Color? inactiveColor;
  final double? lineWidth;

  NumberStepper({
    Key? key,
    @required this.width,
    @required this.curStep,
    @required this.stepCompleteColor,
    @required this.totalSteps,
    @required this.inactiveColor,
    @required this.currentStepColor,
    @required this.lineWidth,
  })  : assert(curStep! > 0 == true && curStep <= totalSteps! + 1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 24.0,
        right: 24.0,
      ),
      width: width,
      child: Row(
        children: _steps(),
      ),
    );
  }

  List<Widget> _steps() {
    var list = <Widget>[];
    for (int i = 0; i < totalSteps!; i++) {
      var circleColor = getCircleColor(i);
      var borderColor = getBorderColor(i);
      var lineColor = getLineColor(i);

      list.add(
        Container(
          width: 28.0,
          height: 28.0,
          child: getInnerElementOfStepper(i),
          decoration: BoxDecoration(
            color: circleColor,
            borderRadius: const BorderRadius.all(Radius.circular(25.0)),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
        ),
      );

      if (i != totalSteps! - 1) {
        list.add(
          Expanded(
            child: Container(
              height: lineWidth,
              color: lineColor,
            ),
          ),
        );
      }
    }
    return list;
  }

  Widget getInnerElementOfStepper(int index) {
    if (index + 1 < curStep!) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 16.0,
      );
    } else if (index + 1 == curStep) {
      return Center(
        child: Text(
          '$curStep',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Color getCircleColor(int i) {
    if (i + 1 < curStep!) {
      return stepCompleteColor!;
    } else if (i + 1 == curStep) {
      return currentStepColor!;
    } else {
      return Colors.white;
    }
  }

  Color getBorderColor(int i) {
    if (i + 1 < curStep!) {
      return stepCompleteColor!;
    } else if (i + 1 == curStep) {
      return currentStepColor!;
    } else {
      return inactiveColor!;
    }
  }

  Color getLineColor(int i) {
    return curStep! > i + 1 ? Colors.blue.withOpacity(0.4) : Colors.grey[200]!;
  }
}
