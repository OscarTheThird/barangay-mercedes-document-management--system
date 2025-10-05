import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_management_system/widgets/downloadpdf.dart';

class BarangayClearanceCertificate extends StatefulWidget {
  final String idNumber;

  const BarangayClearanceCertificate({
    super.key,
    required this.idNumber,
  });

  @override
  State<BarangayClearanceCertificate> createState() => _BarangayClearanceCertificateState();
}

class _BarangayClearanceCertificateState extends State<BarangayClearanceCertificate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? residentData;
  Map<String, Map<String, String>> officialsData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadResidentData(),
        _loadOfficialsData(),
      ]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadResidentData() async {
    // Search through all purok collections with correct document IDs
    final puroks = [
      'PUROK - 1',
      'PUROK - 1A',
      'PUROK - 2',
      'PUROK - 3',
      'PUROK - 4',
      'PUROK - 4A',
      'PUROK - 5',
      'PUROK - 5A',
      'PUROK - 6',
      'PUROK - 7',
      'PUROK - 7A',
      'PUROK - 8',
    ];
    
    for (String purok in puroks) {
      try {
        final snapshot = await _firestore
            .collection('residents')
            .doc(purok)
            .collection('list')
            .where('idNumber', isEqualTo: widget.idNumber)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          residentData = snapshot.docs.first.data();
          return;
        }
      } catch (e) {
        // Continue to next purok if this one fails
        continue;
      }
    }
    
    throw Exception('Resident with ID ${widget.idNumber} not found');
  }

  Future<void> _loadOfficialsData() async {
    final snapshot = await _firestore.collection('barangay_officials').get();
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      officialsData[doc.id] = {
        'name': data['name'] ?? '',
        'title': data['title'] ?? '',
      };
    }
  }

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
                        onPressed: isLoading ? null : () {},
                        tooltip: 'Print',
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        tooltip: 'Download PDF',
                        onPressed: isLoading || residentData == null
                            ? null
                            : () {
                                generateAndDownloadBarangayClearancePDF(
                                  context,
                                  residentData!,
                                  officialsData,
                                );
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
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
        
        // Barangay Chairman
        _buildOfficialName(officialsData['Barangay Chairman']?['name'] ?? 'HON. CHRISTIAN BERNARD J. OÑATE', isBlue: true),
        _buildChairmanTitle('Barangay Chairman'),
        SizedBox(height: 8),
        
        Text('KAGAWAD', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 8),
        
        // Finance Committee
        _buildOfficialName(officialsData['Chairman-Committee on Finance-Budget and Appropriation and Laws and Legal Matters']?['name'] ?? 'HON. FEDERICO M. PORCIL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Finance,\nBudget and Appropriation and Laws\nand Legal Matters'),
        SizedBox(height: 8),
        
        // Social Welfare Committee
        _buildOfficialName(officialsData['Chairman-Committee on Social Welfare and Senior Citizen Affairs and Health and Nutrition-Cleanliness and Sanitation']?['name'] ?? 'HON. LUZVIMINDA G. MAGA', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Social Welfare and\nSenior Citizen Affairs and Health and\nNutrition, Cleanliness and Sanitation'),
        SizedBox(height: 8),
        
        // Purok Affairs Committee
        _buildOfficialName(officialsData['Chairman-Committee on Purok Affairs and Women- Children and Family']?['name'] ?? 'HON. MARICHU P. RACUYAL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Purok Affairs\nand Women, Children and Family'),
        SizedBox(height: 8),
        
        // Disaster Risk Committee
        _buildOfficialName(officialsData['Chairman-Committee on Disaster Risk Reduction and Management and Tourism and Arts and Culture and Environment Protection']?['name'] ?? 'HON. FRANCES ANN C. BERMEJO', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Disaster Risk\nReduction and Management and\nTourism and Arts and Culture and\nEnvironment Protection'),
        SizedBox(height: 8),
        
        // Infrastructure Committee
        _buildOfficialName(officialsData['Chairman-Committee on Infrastructure and Agriculture and Fisheries']?['name'] ?? 'HON. JUSTITO T. UY', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on\nInfrastructure and Agriculture and\nFisheries'),
        SizedBox(height: 8),
        
        // Cooperatives Committee
        _buildOfficialName(officialsData['Chairman-Committee on Cooperatives and Education and Ways and Means']?['name'] ?? 'HON. EDUARDO M. NIEGO', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on\nCooperatives and Education and Ways\nand Means'),
        SizedBox(height: 8),
        
        // Climate Change Committee
        _buildOfficialName(officialsData['Chairman-Committee on Climate Change and Public Safety- Peace and Order']?['name'] ?? 'HON. ANTONIO R. CABAEL', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Climate\nChange and Public Safety, Peace and\nOrder'),
        SizedBox(height: 8),
        
        // Youth Committee
        _buildOfficialName(officialsData['Chairman-Committee on Youth and Sports Development']?['name'] ?? 'HON. VAN JOSHUA NUÑEZ', isBlue: true),
        _buildOfficialTitle('Chairman, Committee on Youth and\nSports Development'),
        SizedBox(height: 12),
        
        // Secretary
        _buildOfficialName(officialsData['Barangay Secretary']?['name'] ?? 'JOANA Z. JABONERO', isBlue: true),
        _buildOfficialTitle('Barangay Secretary'),
        SizedBox(height: 8),
        
        // Treasurer
        _buildOfficialName(officialsData['Barangay Treasurer']?['name'] ?? 'TEODOSIA A. ABAYAN', isBlue: true),
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
    if (residentData == null) return SizedBox();

    final firstname = residentData!['firstname'] ?? '';
    final middlename = residentData!['middlename'] ?? '';
    final lastname = residentData!['lastname'] ?? '';
    final fullName = '$firstname $middlename $lastname'.trim();
    
    final age = _calculateAge(residentData!['birthday']);
    final civilStatus = residentData!['civilStatus'] ?? 'single/married/widow';
    final purok = residentData!['purok'] ?? '___';
    final dateIssued = _getCurrentDate();
    final chairmanName = officialsData['Barangay Chairman']?['name'] ?? 'HON. CHRISTIAN BERNARD J. OÑATE';

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
        
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, color: Colors.black),
            children: [
              TextSpan(text: '       This is to certify that '),
              TextSpan(text: fullName, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ', '),
              TextSpan(text: age, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' years of age, Filipino, '),
              TextSpan(text: civilStatus, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ' and a bonafide resident of Purok '),
              TextSpan(text: purok, style: TextStyle(decoration: TextDecoration.underline)),
              TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
            ],
          ),
        ),
        SizedBox(height: 24),
        
        Text('       This certification is issued upon request of the interested party for whatever legal purpose this may serve.', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.justify),
        SizedBox(height: 24),
        
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
              TextSpan(text: ' at Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
            ],
          ),
        ),
        SizedBox(height: 40),
        
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 40),
          child: Column(
            children: [
              Container(
                width: 200,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        chairmanName,
                        style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1)))),
                    SizedBox(height: 4),
                    Text('Punong Barangay', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 250,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        fullName,
                        style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1)))),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text('Signature over Printed Name', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12)),
              SizedBox(height: 40),
              Text('Paid Under OR # _________________', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12)),
              SizedBox(height: 4),
              Text('Date: _________________', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateAge(String? birthday) {
    if (birthday == null) return '_____';
    try {
      DateTime birth;
      if (birthday.contains('/')) {
        final parts = birthday.split('/');
        birth = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
      } else {
        birth = DateTime.parse(birthday);
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

void showBarangayClearanceCertificate(BuildContext context, String idNumber) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BarangayClearanceCertificate(idNumber: idNumber),
  );
}