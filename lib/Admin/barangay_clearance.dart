import 'package:flutter/material.dart';

class BarangayClearanceTablePage extends StatefulWidget {
  const BarangayClearanceTablePage({super.key});

  @override
  State<BarangayClearanceTablePage> createState() => _BarangayClearanceTablePageState();
}

class _BarangayClearanceTablePageState extends State<BarangayClearanceTablePage> {
  int _rowsPerPage = 10;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rows = [];
    final filtered = rows.where((data) {
      final idMatch = (data['idNumber'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
      final nameMatch = (data['firstname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
          (data['middlename'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) ||
          (data['lastname'] ?? '').toString().toLowerCase().contains(_search.toLowerCase());
      return _search.isEmpty || idMatch || nameMatch;
    }).toList();
    final visible = filtered.take(_rowsPerPage).toList();

    return Center(
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
                    Text('Barangay Clearance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                            setState(() => _rowsPerPage = value);
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
                        onChanged: (value) => setState(() => _search = value),
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
    );
  }
}


