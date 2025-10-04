import 'package:flutter/material.dart';
import 'package:document_management_system/widgets/downloadpdf.dart';

class BarangayClearanceCertificate extends StatelessWidget {
  final Map<String, dynamic> residentData;

  const BarangayClearanceCertificate({
    super.key,
    required this.residentData,
  });

  @override
  Widget build(BuildContext context) {
    const double modalWidth = 700;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: modalWidth,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barangay Clearance Certificate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.print),
                        onPressed: () {},
                        tooltip: 'Print',
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        tooltip: 'Download PDF',
                        onPressed: () {
                          generateAndDownloadBarangayClearancePDF(context, residentData);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: modalWidth,
                  color: Colors.white,
                  padding: EdgeInsets.all(36),
                  child: _buildMainContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[800]!, width: 1),
              ),
              child: Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[800]!, width: 1),
                ),
                padding: EdgeInsets.all(16),
                child: _buildOfficialsColumn(),
              ),
            ),
          ),
          SizedBox(width: 3),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[800]!, width: 1),
              ),
              child: Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[800]!, width: 1),
                ),
                padding: EdgeInsets.all(20),
                child: _buildCertificateContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialsColumn() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          child: Image.asset('assets/images/mercedeslogo.png', fit: BoxFit.contain),
        ),
        SizedBox(height: 16),
        Text('BARANGAY OFFICIALS', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 12),
        _buildOfficialName('HON. CHRISTIAN BERNARD J. OÑATE', isBlue: true),
        _buildChairmanTitle('Barangay Chairman'),
        SizedBox(height: 8),
        Text('KAGAWAD', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 8),
        _buildOfficialName('HON. FEDERICO M. PORCIL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Finance,\nBudget and Appropriation and Laws\nand Legal Matters'),
        SizedBox(height: 8),
        _buildOfficialName('HON. LUZVIMINDA G. MAGA', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Social Welfare and\nSenior Citizen Affairs and Health and\nNutrition, Cleanliness and Sanitation'),
        SizedBox(height: 8),
        _buildOfficialName('HON. MARICHU P. RACUYAL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Purok Affairs\nand Women, Children and Family'),
        SizedBox(height: 8),
        _buildOfficialName('HON. FRANCES ANN C. BERMEJO', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Disaster Risk\nReduction and Management and\nTourism and Arts and Culture and\nEnvironment Protection'),
        SizedBox(height: 8),
        _buildOfficialName('HON. JUSTITO T. UY', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on\nInfrastructure and Agriculture and\nFisheries'),
        SizedBox(height: 8),
        _buildOfficialName('HON. EDUARDO M. NIEGO', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on\nCooperatives and Education and Ways\nand Means'),
        SizedBox(height: 8),
        _buildOfficialName('HON. ANTONIO R. CABAEL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Climate\nChange and Public Safety, Peace and\nOrder'),
        SizedBox(height: 8),
        _buildOfficialName('HON. VAN JOSHUA NUÑEZ', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Youth and\nSports Development'),
        SizedBox(height: 12),
        _buildOfficialName('JOANA Z. JABONERO', isBlue: true),
        _buildOfficialTitle('Barangay Secretary'),
        SizedBox(height: 8),
        _buildOfficialName('TEODOSIA A. ABAYAN', isBlue: true),
        _buildOfficialTitle('Barangay Treasurer'),
      ],
    );
  }

  Widget _buildOfficialName(String name, {bool isBlue = false}) {
    return Text(name, style: TextStyle(fontFamily: 'Times New Roman', fontSize: 11, fontWeight: FontWeight.bold, color: isBlue ? Colors.blue[700] : Colors.black), textAlign: TextAlign.center);
  }

  Widget _buildChairmanTitle(String title) {
    return Text(title, style: TextStyle(fontFamily: 'Times New Roman', fontSize: 11, height: 1.2), textAlign: TextAlign.center);
  }

  Widget _buildOfficialTitle(String title) {
    return Text(title, style: TextStyle(fontFamily: 'Times New Roman', fontSize: 10, height: 1.2), textAlign: TextAlign.center);
  }

  Widget _buildCertificateContent() {
    final fullName = residentData['fullName'] ?? '_____________________';
    final age = _calculateAge(residentData['residentData']);
    final civilStatus = residentData['residentData']?['civilStatus'] ?? 'single/married/widow';
    final purok = residentData['purok'] ?? '___';
    final dateIssued = _getCurrentDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Republic of the Philippines', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 10, height: 1.0), textAlign: TextAlign.center),
        Text('Province of Samar', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 10, height: 1.0), textAlign: TextAlign.center),
        Text('City of Catbalogan', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 10, height: 1.0), textAlign: TextAlign.center),
        SizedBox(height: 12),
        Text('BARANGAY MERCEDES', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]), textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text('Office of the Barangay Chairman', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 16),
        Text('BARANGAY CERTIFICATION', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text('BARANGAY CLEARANCE', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 32),
        Align(alignment: Alignment.centerLeft, child: Text('To Whom this may concern:', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12))),
        SizedBox(height: 16),
        
        // First line with double spacing
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black),
            children: [
              TextSpan(text: '       This is to certify that '),
              TextSpan(text: fullName, style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
              TextSpan(text: ', '),
              TextSpan(text: age, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' years of age, Filipino, '),
              TextSpan(text: civilStatus, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' and a'),
            ],
          ),
        ),
        SizedBox(height: 12),
        
        // Second line
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black),
            children: [
              TextSpan(text: 'bonafide resident of Purok '),
              TextSpan(text: purok, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
            ],
          ),
        ),
        SizedBox(height: 24),
        
        // Second paragraph
        Text('       This certification is issued upon request of the interested', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.justify),
        SizedBox(height: 12),
        Text('party for whatever legal purpose this may serve.', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.justify),
        SizedBox(height: 24),
        
        // Date issued
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black),
            children: [
              TextSpan(text: '       Issued this '),
              TextSpan(text: dateIssued['day'], style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' day of '),
              TextSpan(text: dateIssued['month'], style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ', '),
              TextSpan(text: dateIssued['year'], style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' at Barangay Mercedes,'),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text('Catbalogan City, Samar, Philippines.', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.justify),
        SizedBox(height: 60),
        
        // Signature section
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 40),
          child: Column(
            children: [
              Container(
                width: 200,
                child: Column(
                  children: [
                    Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))), height: 30),
                    SizedBox(height: 4),
                    Text('Punong Barangay', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 60),
        
        // Footer with line
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 250, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))), height: 1),
              SizedBox(height: 4),
              Text('Signature over Printed Name', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12)),
              SizedBox(height: 12),
              RichText(text: TextSpan(style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black), children: [TextSpan(text: 'Paid Under OR # '), TextSpan(text: '__________', style: TextStyle(decoration: TextDecoration.underline))])),
              RichText(text: TextSpan(style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black), children: [TextSpan(text: 'Date: '), TextSpan(text: '__________', style: TextStyle(decoration: TextDecoration.underline))])),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateAge(Map<String, dynamic>? resident) {
    if (resident == null) return '_____';
    final birthdate = resident['birthdate'];
    if (birthdate == null) return '_____';
    try {
      DateTime birth;
      if (birthdate is String) {
        birth = DateTime.parse(birthdate);
      } else if (birthdate is DateTime) {
        birth = birthdate;
      } else {
        return '_____';
      }
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '_____';
    }
  }

  Map<String, String> _getCurrentDate() {
    final now = DateTime.now();
    return {'day': now.day.toString(), 'month': _getMonthName(now.month), 'year': now.year.toString()};
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

void showBarangayClearanceCertificate(BuildContext context, Map<String, dynamic> requestData) {
  showDialog(context: context, barrierDismissible: false, builder: (context) => BarangayClearanceCertificate(residentData: requestData));
}