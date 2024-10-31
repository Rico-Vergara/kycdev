import 'package:ekyc/ui/screens/ekyc_register/pages/ekyc_page_1.dart';
import 'package:ekyc/ui/screens/ekyc_register/pages/ekyc_page_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController(initialPage: 0);
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GetStarted(pageController: _pageController),
      Info(pageController: _pageController),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
      ),
    );
  }
}
