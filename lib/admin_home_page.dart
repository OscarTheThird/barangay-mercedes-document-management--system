import 'package:flutter/material.dart';
import 'barangay_coordinator_page.dart';
import 'residents_record.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // 0 = Dashboard

  final List<Map<String, dynamic>> dashboardStats = [
    {
      'icon': Icons.groups,
      'label': 'POPULATION',
      'value': 100,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFF1976D2), // Blue
    },
    {
      'icon': Icons.male,
      'label': 'MALE',
      'value': 39,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFF43A047), // Green
    },
    {
      'icon': Icons.female,
      'label': 'FEMALE',
      'value': 61,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFFD81B60), // Pink
    },
    {
      'icon': Icons.how_to_vote,
      'label': 'VOTERS',
      'value': 47,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFFF9A825), // Yellow
    },
    {
      'icon': Icons.person,
      'label': 'NON VOTERS',
      'value': 53,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFF6D4C41), // Brown
    },
    {
      'icon': Icons.signpost,
      'label': 'PUROK',
      'value': 13,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFF5E35B1), // Purple
    },
    {
      'icon': Icons.assignment,
      'label': 'BLOTTER',
      'value': 6,
      'sublabel': 'TOTAL POPULATION',
      'color': Color(0xFF757575), // Grey
    },
  ];

  Widget _buildDashboardGrid(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width > 900
        ? 3
        : MediaQuery.of(context).size.width > 600
            ? 2
            : 1;
    List<Widget> rows = [];
    for (int i = 0; i < dashboardStats.length; i += crossAxisCount) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(crossAxisCount, (j) {
            int index = i + j;
            if (index >= dashboardStats.length) return SizedBox(width: 0, height: 0);
            var stat = dashboardStats[index];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: stat['color'],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(stat['icon'], size: 64, color: Colors.black),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  stat['label'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  '${stat['value']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          stat['sublabel'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }
    return Container(
      color: Color(0xFFEAE6FA),
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width > 900 ? 48 : 16),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_selectedIndex == 0) {
      return _buildDashboardGrid(context);
    }
    if (_selectedIndex == 1) {
      // Brgy Officials and Staff Section
      return BarangayCoordinatorContent();
    }
    if (_selectedIndex == 2) {
      // Residents Record Section
      return ResidentsRecordPage();
    }
    // Placeholder for other navs
    return Center(
      child: Text(
        'Section coming soon!',
        style: TextStyle(fontSize: 24, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildResidentsTable() {
    final List<Map<String, dynamic>> residents = [
      {
        'fullname': 'Amorio, Crischel T',
        'nationalId': '000122222',
        'age': 27,
        'civilStatus': 'Single',
        'gender': 'Female',
        'voterStatus': 'No',
      },
      {
        'fullname': 'Cena, John P',
        'nationalId': '1122221212',
        'age': 56,
        'civilStatus': 'Married',
        'gender': 'Male',
        'voterStatus': 'Yes',
      },
      {
        'fullname': 'Jario, Andres P',
        'nationalId': '0000888774445',
        'age': 31,
        'civilStatus': 'Single',
        'gender': 'Male',
        'voterStatus': 'Yes',
      },
      {
        'fullname': 'LeBron, James P',
        'nationalId': '887455898',
        'age': 31,
        'civilStatus': 'Single',
        'gender': 'Male',
        'voterStatus': 'No',
      },
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Fullname')),
          DataColumn(label: Text('National ID')),
          DataColumn(label: Text('Age')),
          DataColumn(label: Text('Civil Status')),
          DataColumn(label: Text('Gender')),
          DataColumn(label: Text('Voter Status')),
          DataColumn(label: Text('Action')),
        ],
        rows: residents.map((resident) {
          return DataRow(cells: [
            DataCell(Text(resident['fullname'])),
            DataCell(Text(resident['nationalId'])),
            DataCell(Text(resident['age'].toString())),
            DataCell(Text(resident['civilStatus'])),
            DataCell(Text(resident['gender'])),
            DataCell(Text(resident['voterStatus'])),
            DataCell(_buildActionMenu()),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle actions here
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit, color: Colors.green), SizedBox(width: 8), Text('Edit')],
          ),
        ),
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text('View')],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Remove')],
          ),
        ),
      ],
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text('Action'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final Color drawerBg = Color(0xFF4632A1);
    final Color iconColor = Colors.white;
    final TextStyle navTextStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15, letterSpacing: 0.5);
    final TextStyle sectionLabelStyle = TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2);

    Widget drawerContent = Container(
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
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
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
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                // Residents Record
                ListTile(
                  leading: Icon(Icons.groups, color: iconColor),
                  title: Text('RESIDENTS RECORD', style: navTextStyle),
                  selected: _selectedIndex == 2,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                // Barangay Certificates
                ListTile(
                  leading: Icon(Icons.emoji_events, color: iconColor),
                  title: Text('BARANGAY CERTIFICATES', style: navTextStyle),
                  selected: _selectedIndex == 3,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                // Certificate of Indigency
                ListTile(
                  leading: Icon(Icons.description, color: iconColor),
                  title: Text('CERTIFICATE OF INDIGENCY', style: navTextStyle),
                  selected: _selectedIndex == 4,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                ),
                // Blotter Records
                ListTile(
                  leading: Icon(Icons.library_books, color: iconColor),
                  title: Text('BLOTTER RECORDS', style: navTextStyle),
                  selected: _selectedIndex == 5,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                    });
                  },
                ),
                // Requested Document
                ListTile(
                  leading: Icon(Icons.request_page, color: iconColor),
                  title: Text('REQUESTED DOCUMENT', style: navTextStyle),
                  selected: _selectedIndex == 6,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 6;
                    });
                  },
                ),
                // House Record
                ListTile(
                  leading: Icon(Icons.house, color: iconColor),
                  title: Text('HOUSE RECORD', style: navTextStyle),
                  selected: _selectedIndex == 7,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 7;
                    });
                  },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 900;
        return Scaffold(
          drawer: isWide ? null : Drawer(child: drawerContent),
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            centerTitle: true,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              _getAppBarTitle(screenWidth),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth > 600 ? 32 : 24,
              ),
            ),
          ),
          body: Row(
            children: [
              if (isWide) drawerContent,
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle(double screenWidth) {
    switch (_selectedIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Brgy Officials and Staff';
      case 2:
        return 'Residents Record';
      case 3:
        return 'Barangay Certificates';
      case 4:
        return 'Certificate of Indigency';
      case 5:
        return 'Blotter Records';
      case 6:
        return 'Requested Document';
      case 7:
        return 'House Record';
      default:
        return 'Admin Dashboard';
    }
  }
} 