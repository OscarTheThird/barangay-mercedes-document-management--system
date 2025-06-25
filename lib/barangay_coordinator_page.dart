import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_home_page.dart';

class BarangayCoordinatorPage extends StatefulWidget {
  @override
  _BarangayCoordinatorPageState createState() => _BarangayCoordinatorPageState();
}

class _BarangayCoordinatorPageState extends State<BarangayCoordinatorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Council structure for diagram
  final List<Map<String, String>> top = [
    {'title': 'Chairman', 'role': 'Mayor'},
  ];
  final List<Map<String, String>> second = [
    {'title': 'Co-Chairman', 'role': 'District Supervisor DepED'},
  ];
  final List<Map<String, String>> members = [
    {'title': 'SB Member - Chairman, Committee on Education', 'role': ''},
    {'title': 'MPDO Member', 'role': ''},
    {'title': 'Department Head - MSWD', 'role': ''},
    {'title': 'Department Head - MHO', 'role': ''},
    {'title': 'MLGOO Member', 'role': ''},
    {'title': 'SB Member - Chairman, Committee on Health', 'role': ''},
    {'title': 'SB Member - Chairman, Committee on Peace and Order', 'role': ''},
    {'title': 'SB Member - Chairman, Committee on Appropriations', 'role': ''},
    {'title': 'Civil Society (NGOs, POs, Civic/Religious Organizations)', 'role': ''},
  ];
  final List<Map<String, String>> secretariat = [
    {'title': 'Secretariat', 'role': 'A secretariat may be organized to handle documentation and other program support function'},
  ];

  Map<String, dynamic> councilData = {};
  bool isLoading = true;

  String safeDocId(String title) => title.replaceAll('/', '-');

  @override
  void initState() {
    super.initState();
    _loadCouncilData();
  }

  Future<void> _loadCouncilData() async {
    final snapshot = await _firestore.collection('barangay_coordinator').get();
    setState(() {
      councilData = {for (var doc in snapshot.docs) doc['title']: doc.data()};
      isLoading = false;
    });
  }

  void _showAddDialog() {
    final allSections = [
      {'label': 'Chairman', 'positions': top},
      {'label': 'Co-Chairman', 'positions': second},
      {'label': 'Members', 'positions': members},
      {'label': 'Secretariat', 'positions': secretariat},
    ];
    final Map<String, TextEditingController> controllers = {
      for (var section in allSections)
        for (var pos in section['positions'] as List<Map<String, String>>) pos['title']!: TextEditingController(),
    };
    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final dialogWidth = width > 700 ? 600.0 : width * 0.98;
        return AlertDialog(
          title: Text('Add Coordinators'),
          content: Container(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var section in allSections) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            section['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        ...((section['positions'] as List<Map<String, String>>).map((pos) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: TextField(
                              controller: controllers[pos['title']!],
                              decoration: InputDecoration(
                                labelText: pos['title'],
                                isDense: true,
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                              minLines: 1,
                              maxLines: null,
                              expands: false,
                              keyboardType: TextInputType.multiline,
                            ),
                          );
                        })),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool anyFilled = false;
                for (var section in allSections) {
                  for (var pos in section['positions'] as List<Map<String, String>>) {
                    final name = controllers[pos['title']!]!.text.trim();
                    if (name.isNotEmpty) {
                      anyFilled = true;
                      await _firestore.collection('barangay_coordinator').doc(safeDocId(pos['title']!)).set({
                        'title': pos['title'],
                        'name': name,
                      });
                    }
                  }
                }
                if (anyFilled) {
                  Navigator.pop(context);
                  _loadCouncilData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully Added!')),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog() {
    final allSections = [
      {'label': 'Chairman', 'positions': top},
      {'label': 'Co-Chairman', 'positions': second},
      {'label': 'Members', 'positions': members},
      {'label': 'Secretariat', 'positions': secretariat},
    ];
    final Map<String, TextEditingController> controllers = {
      for (var section in allSections)
        for (var pos in section['positions'] as List<Map<String, String>>)
          pos['title']!: TextEditingController(
            text: councilData[pos['title']] != null ? councilData[pos['title']]['name'] ?? '' : '',
          ),
    };
    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final dialogWidth = width > 700 ? 600.0 : width * 0.98;
        return AlertDialog(
          title: Text('Edit Coordinators'),
          content: Container(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var section in allSections) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            section['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        ...((section['positions'] as List<Map<String, String>>).map((pos) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: TextField(
                              controller: controllers[pos['title']!],
                              decoration: InputDecoration(
                                labelText: pos['title'],
                                isDense: true,
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                              minLines: 1,
                              maxLines: null,
                              expands: false,
                              keyboardType: TextInputType.multiline,
                            ),
                          );
                        })),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool anyFilled = false;
                for (var section in allSections) {
                  for (var pos in section['positions'] as List<Map<String, String>>) {
                    final name = controllers[pos['title']!]!.text.trim();
                    if (name.isNotEmpty) {
                      anyFilled = true;
                      await _firestore.collection('barangay_coordinator').doc(safeDocId(pos['title']!)).set({
                        'title': pos['title'],
                        'name': name,
                      });
                    }
                  }
                }
                if (anyFilled) {
                  Navigator.pop(context);
                  _loadCouncilData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully Saved!')),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionCard(String title, String? role, Map<String, dynamic>? data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Container(
        width: 220,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 4),
            Text(
              data != null ? 'Name: ${data['name']}' : (role ?? ''),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(String title, String? currentName) {
    final controller = TextEditingController(text: currentName ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await _firestore.collection('barangay_coordinator').doc(safeDocId(title)).set({
                    'title': title,
                    'name': name,
                  });
                  Navigator.pop(context);
                  _loadCouncilData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully Updated!')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final Color drawerBg = Color(0xFF4632A1);
    final Color iconColor = Colors.white;
    final TextStyle navTextStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15, letterSpacing: 0.5);
    final TextStyle sectionLabelStyle = TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2);
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
                // User Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.deepPurple.shade900,
                        child: Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                          Text('Administrator', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Divider(color: Colors.white, thickness: 1, height: 1),
                // Dashboard
                ListTile(
                  leading: Icon(Icons.home, color: iconColor),
                  title: Text('DASHBOARD', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => AdminHomePage()),
                      (route) => false,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                  child: Text('MENU', style: sectionLabelStyle),
                ),
                // Brgy Officials and Staff
                ListTile(
                  leading: Icon(Icons.person, color: iconColor),
                  title: Text('BRGY OFFICIALS AND STAFF', style: navTextStyle),
                  selected: true,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // Residents Record
                ListTile(
                  leading: Icon(Icons.groups, color: iconColor),
                  title: Text('RESIDENTS RECORD', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // Barangay Certificates
                ListTile(
                  leading: Icon(Icons.emoji_events, color: iconColor),
                  title: Text('BARANGAY CERTIFICATES', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // Certificate of Indigency
                ListTile(
                  leading: Icon(Icons.description, color: iconColor),
                  title: Text('CERTIFICATE OF INDIGENCY', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // Blotter Records
                ListTile(
                  leading: Icon(Icons.library_books, color: iconColor),
                  title: Text('BLOTTER RECORDS', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // Requested Document
                ListTile(
                  leading: Icon(Icons.request_page, color: iconColor),
                  title: Text('REQUESTED DOCUMENT', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
                // House Record
                ListTile(
                  leading: Icon(Icons.house, color: iconColor),
                  title: Text('HOUSE RECORD', style: navTextStyle),
                  selected: false,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {},
                ),
              ],
            ),
          ),
          // Logout at the bottom
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final double width = isWide ? 1000 : constraints.maxWidth * 0.98;
        final int memberCount = members.length;
        final double boxMinHeight = 70;
        final scaffoldBody = isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                scrollDirection: Axis.vertical,
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (user != null) ...[
                              ElevatedButton(
                                onPressed: _showAddDialog,
                                child: Text('Add'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _showEditDialog,
                                child: Text('Edit'),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 16),
                        // Chairman
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: boxMinHeight, minWidth: width / 3, maxWidth: width / 2),
                            child: _buildPositionCard('Chairman', top[0]['role'], councilData['Chairman']),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Co-Chairman
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: boxMinHeight, minWidth: width / 2.5, maxWidth: width * 0.7),
                            child: _buildPositionCard('Co-Chairman', second[0]['role'], councilData['Co-Chairman']),
                          ),
                        ),
                        SizedBox(height: 32),
                        // Members
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final ScrollController _scrollController = ScrollController();
                              return Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                thickness: 10,
                                radius: Radius.circular(8),
                                interactive: true,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: members.map((pos) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: 220,
                                            maxWidth: 220,
                                            minHeight: 140,
                                            maxHeight: 140,
                                          ),
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            color: Colors.deepPurple.shade50,
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                                                child: IntrinsicHeight(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          pos['title']!,
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: constraints.maxWidth > 600 ? 16 : 14,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Flexible(
                                                        child: Text(
                                                          councilData[pos['title']] != null
                                                              ? 'Name: ${councilData[pos['title']]['name']}'
                                                              : (pos['role'] ?? ''),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: constraints.maxWidth > 600 ? 14 : 13,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 48),
                        // Secretariat
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: boxMinHeight, minWidth: width / 2.5, maxWidth: width * 0.7),
                            child: _buildPositionCard('Secretariat', secretariat[0]['role'], councilData['Secretariat']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
        if (isWide) {
          // Sidebar layout
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'BRGY OFFICIALS AND STAFF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
                ),
              ),
              backgroundColor: Colors.deepPurple,
              automaticallyImplyLeading: false,
            ),
            body: Row(
              children: [
                _buildDrawer(context),
                Expanded(child: scaffoldBody),
              ],
            ),
          );
        } else {
          // Drawer menu layout
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'BRGY OFFICIALS AND STAFF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
                ),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            drawer: _buildDrawer(context),
            body: scaffoldBody,
          );
        }
      },
    );
  }
} 