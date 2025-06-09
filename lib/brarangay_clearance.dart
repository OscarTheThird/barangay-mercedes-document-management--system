import 'package:flutter/material.dart';

class BarangayClearancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barangay Clearance'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Barangay Clearance Requirements Page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
