import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  final String text;

  const SuggestionCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 500, // fixed height to enable scrolling
          child: SingleChildScrollView(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
