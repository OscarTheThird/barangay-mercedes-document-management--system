import 'package:flutter/material.dart';
import 'barangay_coordinator_page.dart';

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
    return Container(
      color: Color(0xFFEAE6FA),
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width > 900 ? 48 : 16),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1000),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.2,
            children: dashboardStats.map((stat) {
              return Card(
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
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_selectedIndex == 0) {
      return _buildDashboardGrid(context);
    }
    // Placeholder for other navs
    return Center(
      child: Text(
        'Section coming soon!',
        style: TextStyle(fontSize: 24, color: Colors.deepPurple),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => BarangayCoordinatorPage()),
                    );
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
            automaticallyImplyLeading: !isWide, // Remove back arrow on wide screens
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Admin Dashboard',
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
} 