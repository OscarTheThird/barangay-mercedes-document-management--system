import 'package:flutter/material.dart';
import 'barangay_coordinator_page.dart';
import 'residents_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'barangay_certificates.dart';
import 'barangay_clearance.dart';
import 'barangay_indigency.dart';
import 'barangay_blotter.dart';
import 'barangay_complaint.dart';

// IMPORTANT: A new set of index numbers is used for the sub-menu items
// 0: Dashboard
// 1: Brgy Officials and Staff
// 2: Residents Record
// 3: Services (The parent item, its index will trigger the collapse/expand)
// 4: Requested Document (The first item after the new block)
// 5: House Record

// Sub-nav indices for clarity (these aren't used for _selectedIndex, but for logic)
const int SERVICE_CERTIFICATES = 10;
const int SERVICE_INDIGENCY = 11;
const int SERVICE_COMPLAINTS = 12;
const int SERVICE_CLEARANCE = 13;
const int SERVICE_BLOTTER = 14;


class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // 0 = Dashboard
  // New state variable to control the expansion of the 'Services' menu
  bool _isServicesExpanded = false;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        ),
      ),
    );
  }


  // NEW METHOD: Extract the blotter content without the Scaffold wrapper
  Widget _buildBlotterContent(BuildContext context) {
    int _rowsPerPage = 10;
    String _search = '';
    
    final List<Map<String, dynamic>> rows = [];
    final filtered = rows.where((data) {
      final idMatch = (data['idNumber'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
      final nameMatch = (data['firstname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
          (data['middlename'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
          (data['lastname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
      return _search.isEmpty || idMatch || nameMatch;
    }).toList();
    final visible = filtered.take(_rowsPerPage).toList();

    return Container(
      color: Color(0xFFEAE6FA), // Match the dashboard background
      width: double.infinity,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1500),
          padding: EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Barangay Blotter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.file_download, color: Colors.white),
                        label: Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Show'),
                          SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _rowsPerPage,
                            items: [10, 25, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                // Note: This won't work properly with the local variable
                                // You'll need to make _rowsPerPage a class variable for blotter
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          Text('entries'),
                        ],
                      ),
                      Container(
                        width: 220,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          ),
                          onChanged: (value) => setState(() {
                            // Note: This won't work properly with the local variable
                            // You'll need to make _search a class variable for blotter
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 1200),
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowColor: MaterialStateProperty.all(Color(0xFFF6F6FA)),
                            dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) return Colors.deepPurple.shade50;
                              return null;
                            }),
                            dividerThickness: 0.5,
                            columns: const [
                              DataColumn(label: Center(child: Text(''))),
                              DataColumn(label: Center(child: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('House No.', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('Purok', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('Voter Status', style: TextStyle(fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)))),
                            ],
                            rows: List.generate(visible.length, (i) {
                              final data = visible[i];
                              final isEven = i % 2 == 0;
                              return DataRow(
                                color: MaterialStateProperty.all(isEven ? Color(0xFFF8F8FA) : Colors.white),
                                cells: [
                                  DataCell(Center(
                                    child: data['profileImage'] != null && data['profileImage'] != ''
                                        ? CircleAvatar(backgroundImage: NetworkImage(data['profileImage']), radius: 20)
                                        : CircleAvatar(child: Icon(Icons.person), radius: 20),
                                  )),
                                  DataCell(Center(child: Text(data['idNumber'] ?? ''))),
                                  DataCell(Center(
                                    child: Text(
                                      '${data['firstname'] ?? ''}'
                                      '${(data['middlename'] != null && data['middlename'] != '') ? ' ' + data['middlename'] : ''}'
                                      '${(data['lastname'] != null && data['lastname'] != '') ? ' ' + data['lastname'] : ''}',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade900, fontSize: 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                                  DataCell(Center(child: Text(data['householdNo'] ?? ''))),
                                  DataCell(Center(child: Text(data['gender'] ?? ''))),
                                  DataCell(Center(child: Text(data['purok'] ?? ''))),
                                  DataCell(Center(child: Text(data['voterStatus'] ?? ''))),
                                  DataCell(
                                    Center(
                                      child: IconButton(
                                        icon: Icon(Icons.visibility, color: Colors.blue),
                                        tooltip: 'View',
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Showing ${filtered.isEmpty ? 0 : 1} to ${visible.length} of ${filtered.length} entries'),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Handle the new, more organized set of indices
    if (_selectedIndex == 0) {
      return _buildDashboardGrid(context);
    }
    if (_selectedIndex == 1) {
      // Brgy Officials and Staff Section
      return BarangayCoordinatorPage();
    }
    if (_selectedIndex == 2) {
      // Residents Record Section
      return ResidentsRecordPage();
    }
    if (_selectedIndex == SERVICE_CERTIFICATES) {
      // Barangay Certificates
      return BarangayCertificatesPage();
    }
    if (_selectedIndex == SERVICE_INDIGENCY) {
      // Certificate of Indigency
      return BarangayIndigencyTablePage();
    }
    if (_selectedIndex == SERVICE_COMPLAINTS) {
      // Complaints Section
      return Container(
        color: Color(0xFFEAE6FA),
        width: double.infinity,
        child: BarangayComplaintTablePage(),
      );
    }
    if (_selectedIndex == SERVICE_CLEARANCE) {
      // Clearance Section
      return Container(
        color: Color(0xFFEAE6FA),
        width: double.infinity,
        child: BarangayClearanceTablePage(),
      );
    }
    if (_selectedIndex == SERVICE_BLOTTER) {
      // Blotter Records Section
      return Container(
        color: Color(0xFFEAE6FA),
        width: double.infinity,
        child: BarangayBlotterTablePage(),
      );
    }
    if (_selectedIndex == 4) {
      // Requested Document
      return Center(child: Text('Requested Document Page', style: TextStyle(fontSize: 24, color: Colors.deepPurple)));
    }
    if (_selectedIndex == 5) {
      // House Record
      return Center(child: Text('House Record Page', style: TextStyle(fontSize: 24, color: Colors.deepPurple)));
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

  // Helper method to create sub-ListTiles with padding and selected state
  Widget _buildSubNavItem({
    required int index,
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextStyle navTextStyle,
  }) {
    // Determine if the current sub-item is selected, but only if the main Services is expanded
    final bool isSelected = _isServicesExpanded && _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0), // Indentation for sub-item
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: navTextStyle),
        selected: isSelected,
        selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
        onTap: () {
          setState(() {
            _selectedIndex = index;
            // Optionally collapse if an item is selected, or keep expanded
            // _isServicesExpanded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    // var screenHeight = MediaQuery.of(context).size.height; // Not used, removed
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
                      // Collapse services when a main item is clicked
                      _isServicesExpanded = false;
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
                      _isServicesExpanded = false;
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
                      _isServicesExpanded = false;
                    });
                  },
                ),
                // -------------------------------------------------------------------
                // NEW: Services - Collapsible Menu (ExpansionTile)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
                    leading: Icon(Icons.miscellaneous_services, color: iconColor), // Changed icon to a folder for services
                    title: Text('SERVICES', style: navTextStyle.copyWith(
                      color: _isServicesExpanded || (_selectedIndex >= SERVICE_CERTIFICATES && _selectedIndex <= SERVICE_BLOTTER)
                        ? Colors.amber.shade200 // Highlight text when expanded or sub-item selected
                        : Colors.white,
                    )),
                    trailing: Icon(
                      _isServicesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: iconColor,
                    ),
                    initiallyExpanded: _isServicesExpanded,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isServicesExpanded = expanded;
                      });
                    },
                    children: <Widget>[
                      // Barangay Certificates (Icon: Trophy)
                      _buildSubNavItem(
                        index: SERVICE_CERTIFICATES, // 10
                        title: 'BARANGAY CERTIFICATES',
                        icon: Icons.emoji_events,
                        iconColor: iconColor,
                        navTextStyle: navTextStyle,
                      ),
                      // Certificate of Indigency (Icon: Document)
                      _buildSubNavItem(
                        index: SERVICE_INDIGENCY, // 11
                        title: 'CERTIFICATE OF INDIGENCY',
                        icon: Icons.description,
                        iconColor: iconColor,
                        navTextStyle: navTextStyle,
                      ),
                      // Complaints (Icon: Alert)
                      _buildSubNavItem(
                        index: SERVICE_COMPLAINTS, // 12
                        title: 'COMPLAINTS',
                        icon: Icons.report_problem,
                        iconColor: iconColor,
                        navTextStyle: navTextStyle,
                      ),
                      // Clearance (Icon: Check Shield)
                      _buildSubNavItem(
                        index: SERVICE_CLEARANCE, // 13
                        title: 'CLEARANCE',
                        icon: Icons.verified_user,
                        iconColor: iconColor,
                        navTextStyle: navTextStyle,
                      ),
                      // Blotter Records (Icon: Clipboard)
                      _buildSubNavItem(
                        index: SERVICE_BLOTTER, // 14
                        title: 'BLOTTER RECORDS',
                        icon: Icons.library_books,
                        iconColor: iconColor,
                        navTextStyle: navTextStyle,
                      ),
                    ],
                  ),
                ),
                // -------------------------------------------------------------------

                // Requested Document (Index 4)
                ListTile(
                  leading: Icon(Icons.request_page, color: iconColor),
                  title: Text('REQUESTED DOCUMENT', style: navTextStyle),
                  selected: _selectedIndex == 4,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                      _isServicesExpanded = false;
                    });
                  },
                ),
                // House Record (Index 5)
                ListTile(
                  leading: Icon(Icons.house, color: iconColor),
                  title: Text('HOUSE RECORD', style: navTextStyle),
                  selected: _selectedIndex == 5,
                  selectedTileColor: Colors.deepPurple.shade700.withOpacity(0.3),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                      _isServicesExpanded = false;
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
            leading: !isWide
                ? Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, size: 30, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open navigation menu',
                    ),
                  )
                : null,
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
      case SERVICE_CERTIFICATES: // 10
        return 'Barangay Certificates';
      case SERVICE_INDIGENCY: // 11
        return 'Certificate of Indigency';
      case SERVICE_COMPLAINTS: // 12
        return 'Complaints';
      case SERVICE_CLEARANCE: // 13
        return 'Clearance';
      case SERVICE_BLOTTER: // 14
        return 'Blotter Records';
      case 4:
        return 'Requested Document';
      case 5:
        return 'House Record';
      default:
        return 'Admin Dashboard';
    }
  }
}

Future<void> ensureAllPurokDocsExist() async {
  final firestore = FirebaseFirestore.instance;
  final listSnapshots = await firestore.collectionGroup('list').get();

  final purokSet = <String>{};
  for (final doc in listSnapshots.docs) {
    final parent = doc.reference.parent.parent;
    if (parent != null) {
      purokSet.add(parent.id);
    }
  }

  for (final purok in purokSet) {
    final purokDoc = firestore.collection('residents').doc(purok);
    final docSnap = await purokDoc.get();
    if (!docSnap.exists) {
      await purokDoc.set({'createdAt': FieldValue.serverTimestamp()});
      print('Created missing parent doc for $purok');
    }
  }
  print('All missing parent docs created!');
}