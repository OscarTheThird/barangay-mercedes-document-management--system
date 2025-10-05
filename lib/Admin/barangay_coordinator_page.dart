import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_home_page.dart';

class BarangayCoordinatorPage extends StatefulWidget {
  @override
  _BarangayCoordinatorPageState createState() =>
      _BarangayCoordinatorPageState();
}

class _BarangayCoordinatorPageState extends State<BarangayCoordinatorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> chairman = [
    {'title': 'Barangay Chairman', 'role': ''},
  ];

  final List<Map<String, String>> kagawad = [
    {
      'title':
          'Chairman, Committee on Finance, Budget and Appropriation and Laws and Legal Matters',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Social Welfare and Senior Citizen Affairs and Health and Nutrition, Cleanliness and Sanitation',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Purok Affairs and Women, Children and Family',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Disaster Risk Reduction and Management and Tourism and Arts and Culture and Environment Protection',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Infrastructure and Agriculture and Fisheries',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Cooperatives and Education and Ways and Means',
      'role': ''
    },
    {
      'title':
          'Chairman, Committee on Climate Change and Public Safety, Peace and Order',
      'role': ''
    },
    {
      'title': 'Chairman, Committee on Youth and Sports Development',
      'role': ''
    },
  ];

  final List<Map<String, String>> officials = [
    {'title': 'Barangay Secretary', 'role': ''},
    {'title': 'Barangay Treasurer', 'role': ''},
  ];

  Map<String, dynamic> councilData = {};
  bool isLoading = true;

  String safeDocId(String title) =>
      title.replaceAll('/', '-').replaceAll(',', '-');

  @override
  void initState() {
    super.initState();
    _loadCouncilData();
  }

  Future<void> _loadCouncilData() async {
    final snapshot = await _firestore.collection('barangay_officials').get();
    setState(() {
      councilData = {for (var doc in snapshot.docs) doc['title']: doc.data()};
      isLoading = false;
    });
  }

  void _showAddDialog() {
    final allSections = [
      {'label': 'Barangay Chairman', 'positions': chairman},
      {'label': 'Kagawad', 'positions': kagawad},
      {'label': 'Officials', 'positions': officials},
    ];
    final Map<String, TextEditingController> controllers = {
      for (var section in allSections)
        for (var pos in section['positions'] as List<Map<String, String>>)
          pos['title']!: TextEditingController(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Add Barangay Officials',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var section in allSections) ...[
                          if (section != allSections.first)
                            SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              section['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF5B21B6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ...((section['positions']
                                  as List<Map<String, String>>)
                              .map((pos) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pos['title']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A5568),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: controllers[pos['title']!],
                                    decoration: InputDecoration(
                                      hintText: 'Enter name',
                                      filled: true,
                                      fillColor: Color(0xFFF7FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFF5B21B6), width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5B21B6),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          bool anyFilled = false;
                          for (var section in allSections) {
                            for (var pos in section['positions']
                                as List<Map<String, String>>) {
                              final name =
                                  controllers[pos['title']!]!.text.trim();
                              if (name.isNotEmpty) {
                                anyFilled = true;

                                // Add HON. prefix and uppercase for Chairman and Kagawad only
                                String finalName = name;
                                if (section['label'] == 'Barangay Chairman' ||
                                    section['label'] == 'Kagawad') {
                                  // Remove existing HON. if user already typed it
                                  String cleanName = name
                                      .toUpperCase()
                                      .replaceFirst('HON.', '')
                                      .trim();
                                  finalName = 'HON. $cleanName';
                                } else {
                                  // For Secretary and Treasurer, convert to uppercase
                                  finalName = name.toUpperCase();
                                }

                                await _firestore
                                    .collection('barangay_officials')
                                    .doc(safeDocId(pos['title']!))
                                    .set({
                                  'title': pos['title'],
                                  'name': finalName,
                                });
                              }
                            }
                          }
                          if (anyFilled) {
                            Navigator.pop(context);
                            _loadCouncilData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Successfully Added!'),
                                  ],
                                ),
                                backgroundColor: Color(0xFF059669),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter at least one name'),
                                backgroundColor: Color(0xFFDC2626),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog() {
    final allSections = [
      {'label': 'Barangay Chairman', 'positions': chairman},
      {'label': 'Kagawad', 'positions': kagawad},
      {'label': 'Officials', 'positions': officials},
    ];
    final Map<String, TextEditingController> controllers = {
      for (var section in allSections)
        for (var pos in section['positions'] as List<Map<String, String>>)
          pos['title']!: TextEditingController(
            text: councilData[pos['title']] != null
                ? councilData[pos['title']]['name'] ?? ''
                : '',
          ),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Edit Barangay Officials',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var section in allSections) ...[
                          if (section != allSections.first)
                            SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              section['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF5B21B6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ...((section['positions']
                                  as List<Map<String, String>>)
                              .map((pos) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pos['title']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A5568),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: controllers[pos['title']!],
                                    decoration: InputDecoration(
                                      hintText: 'Enter name',
                                      filled: true,
                                      fillColor: Color(0xFFF7FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xFF5B21B6), width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5B21B6),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          // Save all changes to Firestore
                          for (var section in allSections) {
                            for (var pos in section['positions']
                                as List<Map<String, String>>) {
                              final name =
                                  controllers[pos['title']!]!.text.trim();
                              if (name.isNotEmpty) {
                                // Add HON. prefix and uppercase for Chairman and Kagawad only
                                String finalName = name;
                                if (section['label'] == 'Barangay Chairman' ||
                                    section['label'] == 'Kagawad') {
                                  // Remove existing HON. if user already typed it
                                  String cleanName = name
                                      .toUpperCase()
                                      .replaceFirst('HON.', '')
                                      .trim();
                                  finalName = 'HON. $cleanName';
                                } else {
                                  // For Secretary and Treasurer, convert to uppercase
                                  finalName = name.toUpperCase();
                                }

                                await _firestore
                                    .collection('barangay_officials')
                                    .doc(safeDocId(pos['title']!))
                                    .set({
                                  'title': pos['title'],
                                  'name': finalName,
                                });
                              }
                            }
                          }
                          Navigator.pop(context);
                          _loadCouncilData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Updated successfully!'),
                                ],
                              ),
                              backgroundColor: Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final Color drawerBg = Color(0xFF4632A1);
    final Color iconColor = Colors.white;
    final TextStyle navTextStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
        letterSpacing: 0.5);
    final TextStyle sectionLabelStyle = TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2);

    return Container(
      color: drawerBg,
      width: 280,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 24),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.deepPurple.shade900,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          Text('Administrator',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Divider(color: Colors.white, thickness: 1, height: 1),
                ListTile(
                  leading: Icon(Icons.home, color: iconColor),
                  title: Text('DASHBOARD', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AdminHomePage()),
                      (route) => false,
                    );
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: Text('MENU', style: sectionLabelStyle),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: iconColor),
                  title: Text('BRGY OFFICIALS AND STAFF', style: navTextStyle),
                  selected: true,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.groups, color: iconColor),
                  title: Text('RESIDENTS RECORD', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.emoji_events, color: iconColor),
                  title: Text('BARANGAY CERTIFICATES', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.description, color: iconColor),
                  title: Text('CERTIFICATE OF INDIGENCY', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.library_books, color: iconColor),
                  title: Text('BLOTTER RECORDS', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.request_page, color: iconColor),
                  title: Text('REQUESTED DOCUMENT', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.house, color: iconColor),
                  title: Text('HOUSE RECORD', style: navTextStyle),
                  selected: false,
                  selectedTileColor:
                      Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: iconColor),
              title: Text('LOGOUT', style: navTextStyle),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 48),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Action Buttons
              Row(
                children: [
                  if (user != null) ...[
                    ElevatedButton(
                      onPressed: _showAddDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5B21B6),
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Text('Add',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _showEditDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF5B21B6),
                        side: BorderSide(color: Color(0xFF5B21B6), width: 2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Edit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 40),

              // Leadership Section - Barangay Chairman
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isMobile ? 24 : 48),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF5B21B6).withOpacity(0.25),
                          blurRadius: 32,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 32 : 60,
                      vertical: isMobile ? 32 : 48,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isMobile ? 70 : 90,
                          height: isMobile ? 70 : 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.star,
                            size: isMobile ? 35 : 45,
                            color: Color(0xFF5B21B6),
                          ),
                        ),
                        SizedBox(height: 24),
                        Column(
                          children: [
                            Text(
                              councilData['Barangay Chairman'] != null
                                  ? councilData['Barangay Chairman']['name']
                                  : 'Not Assigned',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 20 : 28,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'BARANGAY CHAIRMAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Kagawad Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF5B21B6),
                          width: 4,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'KAGAWAD',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 3;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 1;
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 2;
                        }

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: kagawad.map((pos) {
                            return Container(
                              width: (constraints.maxWidth -
                                      (20 * (crossAxisCount - 1))) /
                                  crossAxisCount,
                              constraints: BoxConstraints(minWidth: 250),
                              child: _buildMemberCard(pos['title']!),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Officials Section (Secretary & Treasurer)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: isMobile
                    ? Column(
                        children: officials.map((pos) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: pos == officials.last ? 0 : 20),
                            child: _buildOfficialCard(pos['title']!, isMobile),
                          );
                        }).toList(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: officials.map((pos) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: _buildOfficialCard(pos['title']!, isMobile),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(String title) {
    final hasData = councilData[title] != null;
    final name = hasData ? councilData[title]['name'] : 'Not Assigned';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5B21B6).withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(28),
      constraints: BoxConstraints(minHeight: 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              color: hasData ? Color(0xFF2D3748) : Color(0xFFA0AEC0),
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: hasData ? Color(0xFF2D3748) : Color(0xFFA0AEC0),
              decorationThickness: 2,
              fontStyle: hasData ? FontStyle.normal : FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF4A5568),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialCard(String title, bool isMobile) {
    final hasData = councilData[title] != null;
    final name = hasData ? councilData[title]['name'] : 'Not Assigned';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D3748).withOpacity(0.2),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 32 : 48,
        vertical: isMobile ? 28 : 36,
      ),
      constraints: BoxConstraints(
        minWidth: isMobile ? double.infinity : 350,
        maxWidth: isMobile ? double.infinity : 400,
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              decorationThickness: 2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}