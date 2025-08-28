import 'package:flutter/material.dart';
import 'package:itonatalaga/widgets/full_image_page.dart';

class Activity2Page extends StatelessWidget {
  const Activity2Page({super.key});
  @override
  Widget build(BuildContext context) {
    return FullImagePage(
      title: 'Chapter 2',
      assetPath: 'assets/activity2.png',
    );
  }
}
