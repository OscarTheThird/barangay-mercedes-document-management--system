import 'package:flutter/material.dart';
import 'brarangay_clearance.dart';
import 'residency_certificate.dart';
import 'barangay_certificate.dart';
import 'barangay_blotter.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Color(0xFFEAE6FA),
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            ServiceCard(
              title: 'BARANGAY CLEARANCE',
              description:
                  'View the requirements needed for Barangay Clearance and acquire online now.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarangayClearancePage()),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            ServiceCard(
              title: 'RESIDENCY CERTIFICATE',
              description:
                  'View the requirements needed for Residency Certificate and acquire online now.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResidencyCertificatePage()),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            ServiceCard(
              title: 'BARANGAY CERTIFICATE',
              description:
                  'Apply for a Barangay Certificate with updated address and purpose.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarangayCertificatePage()),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            ServiceCard(
              title: 'BARANGAY BLOTTER',
              description:
                  'Report incidents or request blotter copies through this service.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarangayBlotterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  ServiceCard({
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(
              'assets/images/mercedeslogo.png',
              height: 80,
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('PROCEED'),
            ),
          ],
        ),
      ),
    );
  }
}
