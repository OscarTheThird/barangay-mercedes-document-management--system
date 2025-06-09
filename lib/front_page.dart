import 'package:flutter/material.dart';
import 'services.dart'; // Assuming this file contains your ServicesPage
import 'login_page.dart'; // <-- import the LoginPage here

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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.miscellaneous_services),
              title: Text('Services'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServicesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'BMDPS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth > 600 ? 32 : 24,
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFEAE6FA),
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Image.asset(
              'assets/images/mercedeslogo.png',
              height: screenWidth > 600 ? 300 : 200,
            ),
            SizedBox(height: screenHeight * 0.05),
            Text(
              'WELCOME TO\nBARANGAY MERCEDES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth > 600 ? 40 : 32,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '54 AH26, Catbalogan City Proper\nAH26, Catbalogan City Proper,\nCatbalogan City, Samar: Monday to Friday (8AM - 5PM)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth > 600 ? 20 : 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
