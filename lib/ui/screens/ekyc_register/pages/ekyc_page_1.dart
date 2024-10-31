import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GetStarted extends StatefulWidget {
  final PageController pageController;

  const GetStarted({Key? key, required this.pageController}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  int activeStep = 0;
  double progress = 0.2;

  void increaseProgress() {
    if (progress < 1) {
      setState(() => progress += 0.2);
    } else {
      setState(() => progress = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: const Center(
            child: Text(
          'Admiral Long KYC',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        )),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Container(
                  //   clipBehavior: Clip.none,
                  //   child: EasyStepper(
                  //     activeStep: activeStep,
                  //     lineStyle: const LineStyle(
                  //       lineLength: 70,
                  //       lineSpace: 0,
                  //       lineType: LineType.normal,
                  //       defaultLineColor: Colors.grey,
                  //       finishedLineColor: Colors.orange,
                  //       lineThickness: 1.5,
                  //     ),
                  //     activeStepTextColor: Colors.black87,
                  //     finishedStepTextColor: Colors.black87,
                  //     titlesAreLargerThanSteps: true,
                  //     internalPadding: 0,
                  //     showLoadingAnimation: false,
                  //     stepRadius: 8,
                  //     showStepBorder: false,
                  //     steps: [
                  //       EasyStep(
                  //           enabled: 0 <= activeStep + 1,
                  //           customStep: CircleAvatar(
                  //             radius: 8,
                  //             backgroundColor: 0 <= activeStep
                  //                 ? Theme.of(context).colorScheme.primary
                  //                 : Theme.of(context).colorScheme.onSurfaceVariant,
                  //           ),
                  //           title: "Awaiting authorization",
                  //           customTitle: const SizedBox(
                  //             width: double.infinity,
                  //             child: Text("Awaiting authorization", textAlign: TextAlign.center),
                  //           )),
                  //       EasyStep(
                  //           enabled: 1 <= activeStep + 1,
                  //           customStep: CircleAvatar(
                  //             radius: 8,
                  //             backgroundColor: 1 <= activeStep
                  //                 ? Theme.of(context).colorScheme.primary
                  //                 : Theme.of(context).colorScheme.onSurfaceVariant,
                  //           ),
                  //           title: "Authorized",
                  //           customTitle: const SizedBox(
                  //             width: double.infinity,
                  //             child: Text("Authorized", textAlign: TextAlign.center),
                  //           )),
                  //       EasyStep(
                  //           enabled: 2 <= activeStep + 1,
                  //           customStep: CircleAvatar(
                  //             radius: 8,
                  //             backgroundColor: 2 <= activeStep
                  //                 ? Theme.of(context).colorScheme.primary
                  //                 : Theme.of(context).colorScheme.onSurfaceVariant,
                  //           ),
                  //           title: "Received",
                  //           customTitle: const SizedBox(
                  //             width: double.infinity,
                  //             child: Text("Received", textAlign: TextAlign.center),
                  //           )),
                  //       EasyStep(
                  //           enabled: 3 <= activeStep + 1,
                  //           customStep: CircleAvatar(
                  //             radius: 8,
                  //             backgroundColor: 3 <= activeStep
                  //                 ? Theme.of(context).colorScheme.primary
                  //                 : Theme.of(context).colorScheme.onSurfaceVariant,
                  //           ),
                  //           title: "Under processing",
                  //           customTitle: const SizedBox(
                  //             width: double.infinity,
                  //             child: Text("Under processing", textAlign: TextAlign.center),
                  //           )),
                  //     ],
                  //     onStepReached: (index) => setState(() => activeStep = index),
                  //   ),
                  // ),
                  SizedBox(height: 50),
                  Image(height: 150, image: AssetImage('assets/security.png')),
                  Text('')
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  foregroundColor: MaterialStateProperty.all(Colors.red),
                  side: MaterialStateProperty.all(BorderSide(color: Colors.red, width: 0.9)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.ease,
                  );
                },
                child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
