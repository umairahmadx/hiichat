import 'package:flutter/material.dart';

class LayoutScreenSize extends StatelessWidget {
  final Widget mobileScreen;
  final Widget wideScreen;
  const LayoutScreenSize(
      {super.key, required this.mobileScreen, required this.wideScreen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        if (constraints.maxWidth < 800) {
          return mobileScreen;
        } else {
          return mobileScreen; // Not created a wide screen so sending the same thing
        }
      },
    );
  }
}
