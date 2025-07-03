import 'package:flutter/material.dart';

class ResidentsRecordPage extends StatefulWidget {
  @override
  _ResidentsRecordPageState createState() => _ResidentsRecordPageState();
}

class _ResidentsRecordPageState extends State<ResidentsRecordPage> {
  final List<Map<String, dynamic>> residents = [
    {
      'fullname': 'Amorio, Crischel T',
      'nationalId': '000122222',
      'age': 27,
      'civilStatus': 'Single',
      'gender': 'Female',
      'voterStatus': 'No',
      'avatar': 'assets/images/avatar1.png',
    },
    {
      'fullname': 'Cena, John P',
      'nationalId': '1122221212',
      'age': 56,
      'civilStatus': 'Married',
      'gender': 'Male',
      'voterStatus': 'Yes',
      'avatar': 'assets/images/avatar2.png',
    },
    {
      'fullname': 'Jario, Andres P',
      'nationalId': '0000888774445',
      'age': 31,
      'civilStatus': 'Single',
      'gender': 'Male',
      'voterStatus': 'Yes',
      'avatar': null,
    },
    {
      'fullname': 'LeBron, James P',
      'nationalId': '887455898',
      'age': 31,
      'civilStatus': 'Single',
      'gender': 'Male',
      'voterStatus': 'No',
      'avatar': 'assets/images/avatar3.png',
    },
  ];
  int _rowsPerPage = 10;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filteredResidents = residents.where((r) =>
      r['fullname'].toLowerCase().contains(_search.toLowerCase()) ||
      r['nationalId'].toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.all(32),
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
                    Text('Residents Record', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showResidentForm(),
                          icon: Icon(Icons.person_add, color: Colors.white),
                          label: Text('+ Resident'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        SizedBox(width: 12),
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
                  ],
                ),
                SizedBox(height: 16),
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
                            setState(() {
                              _rowsPerPage = value!;
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
                        onChanged: (value) {
                          setState(() {
                            _search = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateProperty.all(Color(0xFFF6F6FA)),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) return Colors.deepPurple.shade50;
                        return null;
                      }),
                      dividerThickness: 0.5,
                      columns: [
                        DataColumn(label: Text('Fullname', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('National ID', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Civil Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Voter Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(filteredResidents.take(_rowsPerPage).length, (i) {
                        final resident = filteredResidents[i];
                        final isEven = i % 2 == 0;
                        return DataRow(
                          color: MaterialStateProperty.all(isEven ? Color(0xFFF8F8FA) : Colors.white),
                          cells: [
                            DataCell(Row(
                              children: [
                                resident['avatar'] != null
                                  ? CircleAvatar(radius: 28, backgroundImage: AssetImage(resident['avatar']))
                                  : CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade200, child: Icon(Icons.person, color: Colors.deepPurple, size: 32)),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    resident['fullname'],
                                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade900, fontSize: 15),
                                  ),
                                ),
                              ],
                            )),
                            DataCell(Text(resident['nationalId'])),
                            DataCell(Text(resident['age'].toString())),
                            DataCell(Text(resident['civilStatus'])),
                            DataCell(Text(resident['gender'])),
                            DataCell(Text(resident['voterStatus'])),
                            DataCell(_buildStyledActionMenu(context)),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Showing 1 to ${filteredResidents.length < _rowsPerPage ? filteredResidents.length : _rowsPerPage} of ${filteredResidents.length} entries'),
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
    );
  }

  Widget _buildStyledActionMenu(BuildContext context) {
    final GlobalKey actionKey = GlobalKey();
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Listener(
          onPointerDown: (_) => setState(() => isPressed = true),
          onPointerUp: (_) => setState(() => isPressed = false),
          child: ElevatedButton(
            key: actionKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPressed ? Colors.blue.shade800 : Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              textStyle: TextStyle(color: Colors.white),
              disabledBackgroundColor: Colors.blue,
              disabledForegroundColor: Colors.white,
            ),
            onPressed: () {
              final RenderBox button = actionKey.currentContext!.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  position.dx,
                  position.dy + button.size.height,
                  overlay.size.width - position.dx - button.size.width,
                  overlay.size.height - position.dy - button.size.height,
                ),
                items: [
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
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Action'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResidentForm({Map<String, dynamic>? resident}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 900,
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.deepPurple, size: 28),
                      SizedBox(width: 12),
                      Text(
                        resident == null ? 'Add Resident' : 'Edit Resident',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar and photo upload area
                        Container(
                          width: 220,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(Icons.person, size: 80, color: Colors.grey),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Material(
                                      color: Colors.deepPurple,
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {},
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 18),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.upload_file, color: Colors.deepPurple),
                                label: Text('Upload Photo', style: TextStyle(color: Colors.deepPurple)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(color: Colors.deepPurple),
                                ),
                              ),
                              SizedBox(height: 24),
                              Divider(),
                              SizedBox(height: 8),
                              _residentDropdown(['Household 1', 'Household 2'], 'Select Household No.'),
                            ],
                          ),
                        ),
                        SizedBox(width: 32),
                        // Main form fields
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _residentTextField('Enter Firstname')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('Enter Middlename')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('Enter Lastname')),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _residentTextField('Enter Alias')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('Enter Birthplace')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('dd/mm/yyyy', icon: Icons.calendar_today)),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _residentTextField('Enter Age')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentDropdown(['Single', 'Married', 'Widowed', 'Separated'], 'Select Civil Status')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentDropdown(['Male', 'Female'], 'Select Gender')),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _residentDropdown(['Purok 1', 'Purok 2', 'Purok 3'], 'Select Purok Name')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentDropdown(['Yes', 'No'], 'Select Voters Status')),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _residentTextField('Enter Email')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('Enter Contact Number')),
                                  SizedBox(width: 8),
                                  Expanded(child: _residentTextField('Enter Occupation')),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _residentTextField('Enter Citizenship')),
                                ],
                              ),
                              SizedBox(height: 12),
                              _residentTextField('Enter Address'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _residentTextField(String hint, {IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }

  Widget _residentDropdown(List<String> items, String hint) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }
} 