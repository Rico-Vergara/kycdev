import 'package:ekyc/kyc_directory/custom_widget/button.dart';
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

class StepperScreen extends StatefulWidget {
  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int currentStep = 1;
  final int stepLength = 5;
  bool complete = false;

  // Function to handle 'Next' button press
  void next() {
    if (currentStep < stepLength) {
      goTo(currentStep + 1);
    } else {
      // Handle reaching the final step (optional)
      print("You've reached the final step!");
    }
  }

// Function to handle 'Back' button press
  void back() {
    if (currentStep > 1) {
      goTo(currentStep - 1);
    } else {
      // Handle reaching the first step (optional)
      print("You're at the first step!");
    }
  }

// Function to go to a specific step
  void goTo(int step) {
    if (step >= 1 && step <= stepLength) {
      setState(() {
        currentStep = step;
        if (currentStep > stepLength) {
          complete = true;
        }
      });
    } else {
      // Handle invalid step input (optional)
      print(
          "Invalid step number. Please enter a value between 1 and $stepLength.");
    }
  }

  // Method to get step-specific content
  Widget getStepContent() {
    switch (currentStep) {
      case 1:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First Name cannot be empty';
                      } else if (value.length < 2) {
                        return 'First name is too short';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last Name cannot be empty';
                        } else {
                          return null;
                        }
                      }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone no. cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      // Simple email validation
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Birthdate',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        setState(() {
                          _birthdateController.text = formattedDate;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Birth date cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DefaultButtonWidget(
                        title: 'next',
                        onPressed: currentStep < stepLength
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  next();
                                }
                              }
                            : null, // Disable if already at the last step
                      ),
                      const SizedBox(width: 5.0),
                      DefaultButtonWidget(
                        title: 'back',
                        onPressed: currentStep > 0
                            ? () {
                                back(); // Move to the previous step
                              }
                            : null, // Disable if already at the first step
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case 2:
        return Container(
          color: Colors.red,
          child: Column(
            children: [
              const Icon(Icons.person),
              const Text('Recommended IDs',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Social Security System'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    if (currentStep < stepLength &&
                        _formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      next();
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Unified Multi-Purpose ID'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    print('IconButton pressed');
                  },
                ),
              ),
              ListTile(
                title: const Text('Tax Identification Number'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    print('IconButton pressed');
                  },
                ),
              ),
              ListTile(
                title: const Text('Professional Regulation Commission'),
                trailing: IconButton(
                  icon: const Icon(
                      Icons.arrow_forward_ios), // Replace with the line icon
                  onPressed: () {
                    print('IconButton pressed');
                  },
                ),
              ),
              ListTile(
                title: const Text('Driver\'s License'),
                trailing: IconButton(
                  icon: const Icon(
                      Icons.arrow_forward_ios), // Replace with the line icon
                  onPressed: () {
                    print('IconButton pressed');
                  },
                ),
              ),
              const SizedBox(height: 16),
              DefaultButtonWidget(
                title: 'back',
                onPressed: currentStep > 0
                    ? () {
                        back(); // Move to the previous step
                      }
                    : null, // Disable if already at the first step
              ),
            ],
          ),
        );
      case 3:
        return const Text(
          "This is the content for Step 3",
          style: TextStyle(fontSize: 18),
        );
      case 4:
        return const Text(
          "This is the content for Step 4",
          style: TextStyle(fontSize: 18),
        );
      case 5:
        return const Text(
          "This is the content for Step 5",
          style: TextStyle(fontSize: 18),
        );
      default:
        return const Text(
          "Invalid Step",
          style: TextStyle(fontSize: 18),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          NumberStepper(
            width: MediaQuery.of(context).size.width,
            curStep: currentStep,
            stepCompleteColor: Colors.green,
            currentStepColor: Colors.blue,
            inactiveColor: Colors.grey,
            lineWidth: 4.0,
            totalSteps: stepLength,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            // Step-specific content displayed here
            getStepContent(),

            const SizedBox(height: 50),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton(
            //       onPressed: currentStep > 1 ? back : null,
            //       child: const Text('Back'),
            //     ),
            //     ElevatedButton(
            //       onPressed: currentStep < stepLength ? next : null,
            //       child: const Text('Next'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
