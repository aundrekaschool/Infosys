import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final String title;
  final String assetPath;

  const FullImagePage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(assetPath, fit: BoxFit.cover),
          Positioned(
            top: 20, left: 20,
            child: SafeArea(
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(title),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
