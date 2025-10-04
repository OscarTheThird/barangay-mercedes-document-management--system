import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// PDF color: Blue[700] equivalent
final PdfColor pdfBlue = PdfColor.fromInt(0xFF1976D2);

/// Main function to generate and download the Barangay Clearance PDF
Future<void> generateAndDownloadBarangayClearancePDF(
  BuildContext context,
  Map<String, dynamic> residentData,
) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    final pdf = pw.Document();

    // Load Times New Roman font
    final timesFont = await rootBundle.load('fonts/TIMES.TTF');
    final ttf = pw.Font.ttf(timesFont);

    // Load logo image
    final ByteData logoData =
        await rootBundle.load('assets/images/mercedeslogo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    // Add page with A4 size and margins
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(36), // 0.5 inch margins
        build: (context) => _buildPDFContent(residentData, logoBytes, ttf),
      ),
    );

    // Save PDF
    await _savePDF(pdf, residentData['fullName'] ?? 'Certificate', context);

    // Close loading dialog
    Navigator.of(context).pop();
  } catch (e) {
    // Close loading dialog if open
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating PDF: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}

/// Build the PDF content matching the Flutter UI
pw.Widget _buildPDFContent(
    Map<String, dynamic> data, Uint8List logoBytes, pw.Font ttf) {
  final resident = data['residentData'] ?? {};
  final fullName = data['fullName'] ?? '_____________________';
  final purok = data['purok'] ?? '___';
  final civilStatus = resident['civilStatus'] ?? 'single/married/widow';

  // Calculate age from birthdate
  String age = '_____';
  if (resident['birthdate'] != null) {
    try {
      DateTime birthDate;
      if (resident['birthdate'] is String) {
        birthDate = DateTime.parse(resident['birthdate']);
      } else {
        birthDate = resident['birthdate'].toDate();
      }
      int calculatedAge = DateTime.now().year - birthDate.year;
      if (DateTime.now().month < birthDate.month ||
          (DateTime.now().month == birthDate.month &&
              DateTime.now().day < birthDate.day)) {
        calculatedAge--;
      }
      age = calculatedAge.toString();
    } catch (e) {
      age = '_____';
    }
  }

  // Get current date
  final now = DateTime.now();
  final day = now.day.toString();
  final month = _getMonthName(now.month);
  final year = now.year.toString();

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Left Column - Officials (40% width)
      pw.Expanded(
        flex: 2,
        child: _buildDoubleLineBorder(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo
              pw.Image(pw.MemoryImage(logoBytes), width: 100, height: 100),
              pw.SizedBox(height: 16),

              // Officials Title
              pw.Text(
                'BARANGAY OFFICIALS',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 12),

              // Chairman
              _buildOfficialName('HON. CHRISTIAN BERNARD J. OÑATE', ttf),
              _buildOfficialTitle('Barangay Chairman', ttf, fontSize: 11),
              pw.SizedBox(height: 8),

              // KAGAWAD Title
              pw.Text(
                'KAGAWAD',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),

              // Kagawads with committees
              _buildOfficialName('HON. FEDERICO M. PORCIL', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Finance,\nBudget and Appropriation and Laws\nand Legal Matters',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. LUZVIMINDA G. MAGA', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Social Welfare and\nSenior Citizen Affairs and Health and\nNutrition, Cleanliness and Sanitation',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. MARICHU P. RACUYAL', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Purok Affairs\nand Women, Children and Family',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. FRANCES ANN C. BERMEJO', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Disaster Risk\nReduction and Management and\nTourism and Arts and Culture and\nEnvironment Protection',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. JUSTITO T. UY', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on\nInfrastructure and Agriculture and\nFisheries',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. EDUARDO M. NIEGO', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on\nCooperatives and Education and Ways\nand Means',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. ANTONIO R. CABAEL', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Climate\nChange and Public Safety, Peace and\nOrder',
                  ttf),
              pw.SizedBox(height: 8),

              _buildOfficialName('HON. VAN JOSHUA NUÑEZ', ttf),
              _buildOfficialTitle(
                  'Chairman, Committee on Youth and\nSports Development',
                  ttf),
              pw.SizedBox(height: 12),

              // Secretary
              _buildOfficialName('JOANA Z. JABONERO', ttf),
              _buildOfficialTitle('Barangay Secretary', ttf),
              pw.SizedBox(height: 8),

              // Treasurer
              _buildOfficialName('TEODOSIA A. ABAYAN', ttf),
              _buildOfficialTitle('Barangay Treasurer', ttf),
            ],
          ),
        ),
      ),

      // Gap between columns
      pw.SizedBox(width: 3),

      // Right Column - Certificate (60% width)
      pw.Expanded(
        flex: 3,
        child: _buildDoubleLineBorder(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                'Republic of the Philippines',
                style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Province of Samar',
                style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'City of Catbalogan',
                style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 12),

              // Barangay Mercedes (Blue)
              pw.Text(
                'BARANGAY MERCEDES',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfBlue,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),

              // Office title
              pw.Text(
                'Office of the Barangay Chairman',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 16),

              // Certificate Title (two lines)
              pw.Text(
                'BARANGAY CERTIFICATION',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'BARANGAY CLEARANCE',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 32),

              // "TO WHOM THIS MAY CONCERN"
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'To Whom this may concern:',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 16),

              // Main body text - First line
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  children: [
                    pw.TextSpan(text: '       This is to certify that '),
                    pw.TextSpan(
                      text: fullName,
                      style: pw.TextStyle(
                        font: ttf,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(
                      text: age,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' years of age, Filipino, '),
                    pw.TextSpan(
                      text: civilStatus,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' and a'),
                  ],
                ),
              ),
              pw.SizedBox(height: 12), // Double spacing

              // Second line
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  children: [
                    pw.TextSpan(text: 'bonafide resident of Purok '),
                    pw.TextSpan(
                      text: purok,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24), // Extra spacing before next paragraph

              // Second paragraph - First line
              pw.Text(
                '       This certification is issued upon request of the interested',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12), // Double spacing

              // Second paragraph - Second line
              pw.Text(
                'party for whatever legal purpose this may serve.',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 24), // Extra spacing before next paragraph

              // Date issued - First line
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  children: [
                    pw.TextSpan(text: '       Issued this '),
                    pw.TextSpan(
                      text: day,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' day of '),
                    pw.TextSpan(
                      text: month,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(
                      text: year,
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' at Barangay Mercedes,'),
                  ],
                ),
              ),
              pw.SizedBox(height: 12), // Double spacing

              // Second line of date
              pw.Text(
                'Catbalogan City, Samar, Philippines.',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 60),

              // Signature section
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: pw.EdgeInsets.only(right: 40),
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 200,
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 1),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Punong Barangay',
                            style: pw.TextStyle(font: ttf, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 60),

              // Footer
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Line above "Signature over Printed Name"
                    pw.Container(
                      width: 250,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                        ),
                      ),
                      height: 1,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Signature over Printed Name',
                      style: pw.TextStyle(font: ttf, fontSize: 12),
                    ),
                    pw.SizedBox(height: 12),
                    pw.RichText(
                      text: pw.TextSpan(
                        style: pw.TextStyle(font: ttf, fontSize: 12),
                        children: [
                          pw.TextSpan(text: 'Paid Under OR # '),
                          pw.TextSpan(
                            text: '__________',
                            style: pw.TextStyle(
                              font: ttf,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        style: pw.TextStyle(font: ttf, fontSize: 12),
                        children: [
                          pw.TextSpan(text: 'Date: '),
                          pw.TextSpan(
                            text: '__________',
                            style: pw.TextStyle(
                              font: ttf,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Build double-line border container
pw.Widget _buildDoubleLineBorder({required pw.Widget child}) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: pdfBlue, width: 1),
    ),
    child: pw.Container(
      margin: pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pdfBlue, width: 1),
      ),
      padding: pw.EdgeInsets.all(16),
      child: child,
    ),
  );
}

/// Build official name (blue) with dynamic font size
pw.Widget _buildOfficialName(String name, pw.Font ttf) {
  // Calculate font size based on name length
  double fontSize;
  if (name.length <= 25) {
    fontSize = 11; // Normal size for short names
  } else if (name.length <= 30) {
    fontSize = 10; // Slightly smaller for medium names
  } else if (name.length <= 35) {
    fontSize = 9; // Smaller for longer names
  } else {
    fontSize = 8; // Smallest for very long names
  }

  return pw.Text(
    name,
    style: pw.TextStyle(
      font: ttf,
      fontSize: fontSize,
      fontWeight: pw.FontWeight.bold,
      color: pdfBlue,
    ),
    textAlign: pw.TextAlign.center,
  );
}

/// Build official title
pw.Widget _buildOfficialTitle(String title, pw.Font ttf,
    {double fontSize = 10}) {
  return pw.Text(
    title,
    style: pw.TextStyle(font: ttf, fontSize: fontSize, height: 1.2),
    textAlign: pw.TextAlign.center,
  );
}

/// Get month name
String _getMonthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[month - 1];
}

/// Save PDF to device
Future<void> _savePDF(
  pw.Document pdf,
  String fullName,
  BuildContext context,
) async {
  try {
    final bytes = await pdf.save();
    final fileName = '$fullName - Barangay Clearance.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved: ${file.path}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () async {
                await Printing.sharePdf(bytes: bytes, filename: fileName);
              },
            ),
          ),
        );
      } catch (e) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF ready to download'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    throw Exception('Failed to save PDF: $e');
  }
}