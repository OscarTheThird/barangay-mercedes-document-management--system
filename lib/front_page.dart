import 'package:flutter/material.dart';

void main() => runApp(BMDPSApp());

class BMDPSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMDPS',
      home: BarangayMercedesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BarangayMercedesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen size using MediaQuery
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Drawer(
        // Optional: Add drawer items here
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text('Home')),
            // Add more ListTiles if needed
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true, // This centers the title in the AppBar
        title: Text(
          'BMDPS',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
            fontSize: screenWidth > 600
                ? 32
                : 24, // Adjust font size for larger screens
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFEAE6FA),
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the content horizontally
          children: [
            SizedBox(
                height: screenHeight * 0.05), // Responsive vertical spacing
            Image.asset(
              'assets/images/mercedeslogo.png', // Make sure to add this image in pubspec.yaml
              height: screenWidth > 600
                  ? 300
                  : 200, // Make the logo larger on larger screens
            ),
            SizedBox(
                height: screenHeight * 0.05), // Responsive vertical spacing
            Text(
              'WELCOME TO\nBARANGAY MERCEDES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth > 600
                    ? 40
                    : 32, // Make text larger on larger screens
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(
                height: screenHeight * 0.02), // Responsive vertical spacing
            Text(
              '54 AH26, Catbalogan City Proper\nAH26, Catbalogan City Proper,\nCatbalogan City, Samar: Monday to Friday (8AM - 5PM)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth > 600
                    ? 20
                    : 18, // Make text larger on larger screens
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
