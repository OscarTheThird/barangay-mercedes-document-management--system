import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CertificationPdfGenerator {
  // Adjusted to match reference image - bigger logo, closer to text
  static const double logoSize = 95.0;
  static const double logoSpacing = 12.0;
  static const double logoRightMargin = 107.0;

  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      
      // Check if word is a suffix like Jr., Sr., II, III, IV, V
      final lowerWord = word.toLowerCase();
      if (lowerWord == 'jr.' || lowerWord == 'jr') {
        return 'Jr.';
      } else if (lowerWord == 'sr.' || lowerWord == 'sr') {
        return 'Sr.';
      } else if (lowerWord == 'ii') {
        return 'II';
      } else if (lowerWord == 'iii') {
        return 'III';
      } else if (lowerWord == 'iv') {
        return 'IV';
      } else if (lowerWord == 'v') {
        return 'V';
      }
      
      // Otherwise, capitalize only first letter
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static Future<pw.Document> _generatePDF({
    required String name,
    required String age,
    required String civilStatus,
    required String purok,
    required String punongBarangayName,
  }) async {
    final pdf = pw.Document();
    
    final timesRomanData = await rootBundle.load('fonts/TIMES.TTF');
    final timesRoman = pw.Font.ttf(timesRomanData);
    
    final timesRomanBoldData = await rootBundle.load('fonts/TIMESBD.TTF');
    final timesRomanBold = pw.Font.ttf(timesRomanBoldData);
    
    final logoData = await rootBundle.load('assets/images/mercedeslogo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Get current date
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = DateFormat('MMMM').format(now);
    final year = now.year.toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(72),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logoImage, width: logoSize, height: logoSize),
                  pw.SizedBox(width: logoSpacing),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Republic of the Philippines',
                          style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0.2),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Province of Samar',
                          style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0.2),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Catbalogan City',
                          style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0.2),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '-oOo-',
                          style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0.2),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: logoRightMargin),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'OFFICE OF THE BARANGAY CHAIRMAN',
                style: pw.TextStyle(font: timesRomanBold, fontSize: 14, lineSpacing: 0),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'CERTIFICATION',
                style: pw.TextStyle(font: timesRomanBold, fontSize: 24, lineSpacing: 0),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'TO WHOM IT MAY CONCERN:',
                  style: pw.TextStyle(font: timesRomanBold, fontSize: 15, lineSpacing: 0),
                ),
              ),
              pw.SizedBox(height: 28),
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: timesRoman, fontSize: 14, height: 2.0),
                  children: [
                    pw.TextSpan(text: '          This is to CERTIFY that '),
                    pw.TextSpan(
                      text: _toTitleCase(name),
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(
                      text: age,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' years of age, Filipino Citizen, '),
                    pw.TextSpan(
                      text: civilStatus,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' and a resident of Purok '),
                    pw.TextSpan(
                      text: purok,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 28),
              pw.Text(
                '          This certification is issued upon request of the interested party for whatever legal purpose this may serve.',
                style: pw.TextStyle(font: timesRoman, fontSize: 14, height: 2.0),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 28),
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: timesRoman, fontSize: 14, height: 2.0),
                  children: [
                    pw.TextSpan(text: '          Issued this '),
                    pw.TextSpan(
                      text: day,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' day of '),
                    pw.TextSpan(
                      text: month,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ', '),
                    pw.TextSpan(
                      text: year,
                      style: pw.TextStyle(
                        font: timesRoman,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.TextSpan(text: ' at Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 100),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 250,
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                        ),
                      ),
                      child: pw.Text(
                        punongBarangayName,
                        style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Punong Barangay',
                      style: pw.TextStyle(font: timesRoman, fontSize: 14, lineSpacing: 0),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> generateAndDownload({
    required String name,
    required String age,
    required String civilStatus,
    required String purok,
    required String punongBarangayName,
  }) async {
    try {
      final pdf = await _generatePDF(
        name: name,
        age: age,
        civilStatus: civilStatus,
        purok: purok,
        punongBarangayName: punongBarangayName,
      );

      final bytes = await pdf.save();
      final fileName = '$name - Barangay Certification.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(bytes);
        } catch (e) {
          await Printing.sharePdf(bytes: bytes, filename: fileName);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> printDocument({
    required String name,
    required String age,
    required String civilStatus,
    required String purok,
    required String punongBarangayName,
  }) async {
    try {
      final pdf = await _generatePDF(
        name: name,
        age: age,
        civilStatus: civilStatus,
        purok: purok,
        punongBarangayName: punongBarangayName,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      rethrow;
    }
  }
}