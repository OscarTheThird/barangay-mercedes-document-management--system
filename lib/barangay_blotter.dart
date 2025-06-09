import 'package:flutter/material.dart';

class BarangayBlotterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barangay Blotter'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Barangay Blotter Page Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
