import 'package:flutter/material.dart';
import 'package:itonatalaga/widgets/full_image_page.dart';

class Activity1Page extends StatelessWidget {
  const Activity1Page({super.key});
  @override
  Widget build(BuildContext context) {
    return FullImagePage( // no const
      title: 'Chapter 1',
      assetPath: 'assets/activity1.png',
    );
  }
}
