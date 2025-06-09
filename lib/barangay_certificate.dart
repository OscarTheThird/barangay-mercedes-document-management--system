import 'package:flutter/material.dart';

class BarangayCertificatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barangay Certificate'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Barangay Certificate Page Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
