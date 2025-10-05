import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

final PdfColor pdfBlue = PdfColor.fromInt(0xFF1976D2);

Future<void> generateAndDownloadBarangayClearancePDF(
  BuildContext context,
  Map<String, dynamic> residentData,
  Map<String, Map<String, String>> officialsData,
) async {
  try {
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
    final timesFont = await rootBundle.load('fonts/TIMES.TTF');
    final ttf = pw.Font.ttf(timesFont);
    final ByteData logoData = await rootBundle.load('assets/images/mercedeslogo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(36),
        build: (context) => _buildPDFContent(residentData, officialsData, logoBytes, ttf),
      ),
    );

    final firstname = residentData['firstname'] ?? '';
    final lastname = residentData['lastname'] ?? '';
    await _savePDF(pdf, '$firstname $lastname', context);

    Navigator.of(context).pop();
  } catch (e) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating PDF: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}

pw.Widget _buildPDFContent(
  Map<String, dynamic> data,
  Map<String, Map<String, String>> officials,
  Uint8List logoBytes,
  pw.Font ttf,
) {
  final firstname = data['firstname'] ?? '';
  final middlename = data['middlename'] ?? '';
  final lastname = data['lastname'] ?? '';
  final fullName = '$firstname $middlename $lastname'.trim();
  
  final purok = data['purok'] ?? '___';
  final civilStatus = data['civilStatus'] ?? 'single/married/widow';
  final birthday = data['birthday'];
  
  String age = '_____';
  if (birthday != null) {
    try {
      DateTime birthDate;
      if (birthday is String && birthday.contains('/')) {
        final parts = birthday.split('/');
        birthDate = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
      } else if (birthday is String) {
        birthDate = DateTime.parse(birthday);
      } else {
        birthDate = birthday.toDate();
      }
      int calculatedAge = DateTime.now().year - birthDate.year;
      if (DateTime.now().month < birthDate.month ||
          (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
        calculatedAge--;
      }
      age = calculatedAge.toString();
    } catch (e) {
      age = '_____';
    }
  }

  final now = DateTime.now();
  final day = now.day.toString();
  final month = _getMonthName(now.month);
  final year = now.year.toString();
  
  final chairmanName = officials['Barangay Chairman']?['name'] ?? 'HON. CHRISTIAN BERNARD J. OÑATE';

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 2,
        child: _buildDoubleLineBorder(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(pw.MemoryImage(logoBytes), width: 100, height: 100),
              pw.SizedBox(height: 16),
              pw.Text('BARANGAY OFFICIALS', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 12),
              
              _buildOfficialName(officials['Barangay Chairman']?['name'] ?? 'HON. CHRISTIAN BERNARD J. OÑATE', ttf),
              _buildOfficialTitle('Barangay Chairman', ttf, fontSize: 11),
              pw.SizedBox(height: 8),
              
              pw.Text('KAGAWAD', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Finance-Budget and Appropriation and Laws and Legal Matters']?['name'] ?? 'HON. FEDERICO M. PORCIL', ttf),
              _buildOfficialTitle('Chairman, Committee on Finance,\nBudget and Appropriation and Laws\nand Legal Matters', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Social Welfare and Senior Citizen Affairs and Health and Nutrition-Cleanliness and Sanitation']?['name'] ?? 'HON. LUZVIMINDA G. MAGA', ttf),
              _buildOfficialTitle('Chairman, Committee on Social Welfare and\nSenior Citizen Affairs and Health and\nNutrition, Cleanliness and Sanitation', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Purok Affairs and Women- Children and Family']?['name'] ?? 'HON. MARICHU P. RACUYAL', ttf),
              _buildOfficialTitle('Chairman, Committee on Purok Affairs\nand Women, Children and Family', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Disaster Risk Reduction and Management and Tourism and Arts and Culture and Environment Protection']?['name'] ?? 'HON. FRANCES ANN C. BERMEJO', ttf),
              _buildOfficialTitle('Chairman, Committee on Disaster Risk\nReduction and Management and\nTourism and Arts and Culture and\nEnvironment Protection', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Infrastructure and Agriculture and Fisheries']?['name'] ?? 'HON. JUSTITO T. UY', ttf),
              _buildOfficialTitle('Chairman, Committee on\nInfrastructure and Agriculture and\nFisheries', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Cooperatives and Education and Ways and Means']?['name'] ?? 'HON. EDUARDO M. NIEGO', ttf),
              _buildOfficialTitle('Chairman, Committee on\nCooperatives and Education and Ways\nand Means', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Climate Change and Public Safety- Peace and Order']?['name'] ?? 'HON. ANTONIO R. CABAEL', ttf),
              _buildOfficialTitle('Chairman, Committee on Climate\nChange and Public Safety, Peace and\nOrder', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Chairman-Committee on Youth and Sports Development']?['name'] ?? 'HON. VAN JOSHUA NUÑEZ', ttf),
              _buildOfficialTitle('Chairman, Committee on Youth and\nSports Development', ttf),
              pw.SizedBox(height: 12),
              
              _buildOfficialName(officials['Barangay Secretary']?['name'] ?? 'JOANA Z. JABONERO', ttf),
              _buildOfficialTitle('Barangay Secretary', ttf),
              pw.SizedBox(height: 8),
              
              _buildOfficialName(officials['Barangay Treasurer']?['name'] ?? 'TEODOSIA A. ABAYAN', ttf),
              _buildOfficialTitle('Barangay Treasurer', ttf),
            ],
          ),
        ),
      ),
      pw.SizedBox(width: 3),
      pw.Expanded(
        flex: 3,
        child: _buildDoubleLineBorder(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Republic of the Philippines', style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0), textAlign: pw.TextAlign.center),
              pw.Text('Province of Samar', style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0), textAlign: pw.TextAlign.center),
              pw.Text('City of Catbalogan', style: pw.TextStyle(font: ttf, fontSize: 10, height: 1.0), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 12),
              pw.Text('BARANGAY MERCEDES', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold, color: pdfBlue), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Text('Office of the Barangay Chairman', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 16),
              pw.Text('BARANGAY CERTIFICATION', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.Text('BARANGAY CLEARANCE', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 32),
              pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('To Whom this may concern:', style: pw.TextStyle(font: ttf, fontSize: 12))),
              pw.SizedBox(height: 16),
              
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  children: [
                    pw.TextSpan(text: '       This is to certify that '),
                    pw.TextSpan(text: fullName, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(text: age, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ' years of age, Filipino, '),
                    pw.TextSpan(text: civilStatus, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ' and a bonafide resident of Purok '),
                    pw.TextSpan(text: purok, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              pw.Text('       This certification is issued upon request of the interested party for whatever legal purpose this may serve.', style: pw.TextStyle(font: ttf, fontSize: 12), textAlign: pw.TextAlign.justify),
              pw.SizedBox(height: 24),
              
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  children: [
                    pw.TextSpan(text: '       Issued this '),
                    pw.TextSpan(text: day, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ' day of '),
                    pw.TextSpan(text: month, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(text: year, style: pw.TextStyle(font: ttf, decoration: pw.TextDecoration.underline)),
                    pw.TextSpan(text: ' at Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              
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
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(chairmanName, style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                          ),
                          pw.Container(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 1)))),
                          pw.SizedBox(height: 4),
                          pw.Text('Punong Barangay', style: pw.TextStyle(font: ttf, fontSize: 12), textAlign: pw.TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 150,
                      child: pw.Column(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(fullName, style: pw.TextStyle(font: ttf, fontSize: 12), textAlign: pw.TextAlign.center),
                          ),
                          pw.Container(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)))),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Signature over Printed Name', style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.SizedBox(height: 40),
                    pw.Text('Paid Under OR # _________________', style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Date: _________________', style: pw.TextStyle(font: ttf, fontSize: 12)),
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

pw.Widget _buildDoubleLineBorder({required pw.Widget child}) {
  return pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(color: pdfBlue, width: 1)),
    child: pw.Container(
      margin: pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: pdfBlue, width: 1)),
      padding: pw.EdgeInsets.all(16),
      child: child,
    ),
  );
}

pw.Widget _buildOfficialName(String name, pw.Font ttf) {
  double fontSize;
  if (name.length <= 25) {
    fontSize = 11;
  } else if (name.length <= 30) {
    fontSize = 10;
  } else if (name.length <= 35) {
    fontSize = 9;
  } else {
    fontSize = 8;
  }
  return pw.Text(name, style: pw.TextStyle(font: ttf, fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: pdfBlue), textAlign: pw.TextAlign.center);
}

pw.Widget _buildOfficialTitle(String title, pw.Font ttf, {double fontSize = 10}) {
  return pw.Text(title, style: pw.TextStyle(font: ttf, fontSize: fontSize, height: 1.2), textAlign: pw.TextAlign.center);
}

String _getMonthName(int month) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return months[month - 1];
}

Future<void> _savePDF(pw.Document pdf, String fullName, BuildContext context) async {
  try {
    final bytes = await pdf.save();
    final fileName = '$fullName - Barangay Clearance.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF downloaded successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
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
          SnackBar(content: Text('PDF ready to download'), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
        );
      }
    }
  } catch (e) {
    throw Exception('Failed to save PDF: $e');
  }
}