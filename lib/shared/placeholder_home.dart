import 'package:flutter/material.dart';

/// Temporary landing screen for the scaffold branch. It is replaced by the
/// real search screen in the `feat/search-screen` branch.
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Bookkeeper')),
      body: const Center(
        child: Text('The Bookkeeper — scaffold ready.'),
      ),
    );
  }
}
