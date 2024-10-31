import 'package:avatar_view/avatar_view.dart';
import 'package:ekyc/ui/screens/ekyc_register/main_page.dart';
import 'package:flutter/material.dart';

class AdmiralLongKycPage extends StatefulWidget {
  const AdmiralLongKycPage({super.key});

  @override
  State<AdmiralLongKycPage> createState() => _AdmiralLongKycPageState();
}

class _AdmiralLongKycPageState extends State<AdmiralLongKycPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Center(
            child: Text(
          'Admiral Long KYC',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '34567890',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 40),
            ),
            AvatarView(
              radius: 120,
              borderWidth: 6,
              borderColor: Colors.red,
              avatarType: AvatarType.CIRCLE,
              backgroundColor: Colors.red,
              imagePath: "assets/img.png",
              placeHolder: Container(
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              errorWidget: Container(
                child: Icon(
                  Icons.error,
                  size: 50,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "ADMIRAL LONG",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 100),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 50,
                    child: const Center(
                        child: Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )))),
          ],
        ),
      ),
    );
  }
}
