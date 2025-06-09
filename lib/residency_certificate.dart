import 'package:flutter/material.dart';

class ResidencyCertificatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Residency Certificate'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Residency Certificate Requirements Page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
