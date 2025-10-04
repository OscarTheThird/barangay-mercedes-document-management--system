import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BarangayBlotterTablePage extends StatefulWidget {
  const BarangayBlotterTablePage({super.key});

  @override
  State<BarangayBlotterTablePage> createState() =>
      _BarangayBlotterTablePageState();
}

class _BarangayBlotterTablePageState extends State<BarangayBlotterTablePage> {
  int _rowsPerPage = 10;
  String _search = '';
  String _statusFilter = 'All';

  final List<String> _statusOptions = [
    'All',
    'pending',
    'approved',
    'rejected'
  ];

  final List<String> _puroks = [
    '1',
    '1A',
    '2',
    '3',
    '4',
    '4A',
    '5',
    '5A',
    '6',
    '7',
    '7A',
    '8',
  ];

  Future<Map<String, dynamic>?> getResidentByIdNumber(String idNumber) async {
    for (String purok in _puroks) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('residents')
            .doc(purok)
            .collection('list')
            .where('idNumber', isEqualTo: idNumber)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.data();
        }
      } catch (e) {
        debugPrint('Error querying purok $purok: $e');
      }
    }
    return null;
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  String buildFullName(Map<String, dynamic>? resident) {
    if (resident == null) return 'Unknown';
    final firstname = resident['firstname'] ?? '';
    final middlename = resident['middlename'] ?? '';
    final lastname = resident['lastname'] ?? '';
    String fullName = firstname;
    if (middlename.isNotEmpty) fullName += ' $middlename';
    if (lastname.isNotEmpty) fullName += ' $lastname';
    return fullName.trim().isEmpty ? 'Unknown' : fullName.trim();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('barangay_blotter')
          .doc(docId)
          .update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDetailsDialog(Map<String, dynamic> data) {
    final blotter = data['blotter'];
    final resident = data['resident'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 700,
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Blotter Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      _buildDetailRow(
                          'Request ID', blotter['requestId'] ?? 'N/A'),
                      _buildDetailRow(
                          'Date Submitted', blotter['dateSubmitted'] ?? 'N/A'),
                      _buildDetailRow(
                          'Status',
                          (blotter['status'] ?? 'pending')
                              .toString()
                              .toUpperCase()),
                      SizedBox(height: 20),
                      _buildSectionTitle('Submitter Information'),
                      _buildDetailRow(
                          'ID Number', blotter['idNumber'] ?? 'N/A'),
                      _buildDetailRow(
                          'Full Name', data['submittedBy'] ?? 'Unknown'),
                      _buildDetailRow('Purok', data['submitterPurok'] ?? 'N/A'),
                      _buildDetailRow(
                          'Contact', data['submitterContact'] ?? 'N/A'),
                      if (resident != null) ...[
                        _buildDetailRow(
                            'Age', resident['age']?.toString() ?? 'N/A'),
                        _buildDetailRow('Gender', resident['gender'] ?? 'N/A'),
                        _buildDetailRow(
                            'Civil Status', resident['civilStatus'] ?? 'N/A'),
                        _buildDetailRow(
                            'Voter Status', resident['voterStatus'] ?? 'N/A'),
                        _buildDetailRow(
                            'Address', resident['address'] ?? 'N/A'),
                      ],
                      SizedBox(height: 20),
                      _buildSectionTitle('Parties Involved'),
                      _buildDetailRow('Tag-blotter (Complainant)',
                          blotter['tagBlotter'] ?? 'N/A'),
                      _buildDetailRow('Tag-blotter Address',
                          blotter['tagBlotterAddress'] ?? 'N/A'),
                      _buildDetailRow('Gin-blotter (Respondent)',
                          blotter['ginBlotter'] ?? 'N/A'),
                      _buildDetailRow('Gin-blotter Address',
                          blotter['ginBlotterAddress'] ?? 'N/A'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Incident Details (5W1H)'),
                      _buildExpandableDetail('WHAT (Incident Description)',
                          blotter['what'] ?? 'No description provided'),
                      SizedBox(height: 12),
                      _buildDetailRow(
                          'WHEN (Date/Time)', blotter['when'] ?? 'N/A'),
                      _buildDetailRow(
                          'WHERE (Location)', blotter['where'] ?? 'N/A'),
                      SizedBox(height: 12),
                      _buildExpandableDetail(
                          'WHY (Reason)', blotter['why'] ?? 'Not specified'),
                      SizedBox(height: 12),
                      _buildExpandableDetail('HOW (How it happened)',
                          blotter['how'] ?? 'Not specified'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Disposition'),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          blotter['disposition'] ?? 'No disposition yet',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child:
                Text('$label:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildExpandableDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _buildTableData(
      List<QueryDocumentSnapshot> docs) async {
    List<Map<String, dynamic>> tableData = [];

    for (var doc in docs) {
      final blotterData = doc.data() as Map<String, dynamic>;
      final idNumber = blotterData['idNumber'] ?? '';
      final resident = await getResidentByIdNumber(idNumber);

      tableData.add({
        'docId': doc.id,
        'blotter': {
          'requestId': blotterData['requestId'] ?? doc.id,
          'idNumber': idNumber,
          'tagBlotter': blotterData['tagBlotter'] ?? 'N/A',
          'tagBlotterAddress': blotterData['tagBlotterAddress'] ?? 'N/A',
          'ginBlotter': blotterData['ginBlotter'] ?? 'N/A',
          'ginBlotterAddress': blotterData['ginBlotterAddress'] ?? 'N/A',
          'what': blotterData['what'] ?? 'No description',
          'when': blotterData['when'] ?? 'N/A',
          'where': blotterData['where'] ?? 'N/A',
          'why': blotterData['why'] ?? 'N/A',
          'how': blotterData['how'] ?? 'N/A',
          'disposition': blotterData['disposition'] ?? 'N/A',
          'status': blotterData['status'] ?? 'pending',
          'dateSubmitted': formatDate(blotterData['timestamp']),
        },
        'resident': resident,
        'submittedBy': buildFullName(resident),
        'submitterPurok': resident?['purok'] ?? 'N/A',
        'submitterContact':
            resident?['contact'] ?? resident?['contactNumber'] ?? 'N/A',
      });
    }

    return tableData;
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    return data.where((item) {
      final blotter = item['blotter'];

      if (_statusFilter != 'All' &&
          blotter['status'].toString().toLowerCase() !=
              _statusFilter.toLowerCase()) {
        return false;
      }

      if (_search.isNotEmpty) {
        final searchLower = _search.toLowerCase();
        final requestIdMatch =
            blotter['requestId'].toString().toLowerCase().contains(searchLower);
        final idMatch =
            blotter['idNumber'].toString().toLowerCase().contains(searchLower);
        final nameMatch =
            item['submittedBy'].toString().toLowerCase().contains(searchLower);
        final tagMatch = blotter['tagBlotter']
            .toString()
            .toLowerCase()
            .contains(searchLower);
        final ginMatch = blotter['ginBlotter']
            .toString()
            .toLowerCase()
            .contains(searchLower);

        return requestIdMatch || idMatch || nameMatch || tagMatch || ginMatch;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1500),
        padding: EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Barangay Blotter',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Export CSV feature coming soon')),
                        );
                      },
                      icon: Icon(Icons.file_download, color: Colors.white),
                      label: Text('Export CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          items: [10, 25, 50]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _rowsPerPage = value);
                          },
                        ),
                        SizedBox(width: 8),
                        Text('entries'),
                        SizedBox(width: 24),
                        Text('Status:'),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _statusFilter,
                          items: _statusOptions
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e.toUpperCase())))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _statusFilter = value);
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 250,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by ID or Name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('barangay_blotter')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Error loading data',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(snapshot.error.toString(),
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading blotter records...'),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No blotter records found',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: _buildTableData(snapshot.data!.docs),
                        builder: (context, dataSnapshot) {
                          if (dataSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (dataSnapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Error processing data: ${dataSnapshot.error}',
                                  style: TextStyle(color: Colors.red)),
                            );
                          }

                          final allData = dataSnapshot.data ?? [];
                          final filtered = _filterData(allData);
                          final visible = filtered.take(_rowsPerPage).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No results found',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text('Try adjusting your filters',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2)
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(minWidth: 1400),
                                          child: DataTable(
                                            columnSpacing: 16,
                                            headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFFF6F6FA)),
                                            dividerThickness: 0.5,
                                            columns: const [
                                              DataColumn(
                                                  label: Text('Request ID',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('ID Number',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Submitted By',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Purok',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Tag-blotter',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Gin-blotter',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('What',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('When',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Where',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Date Submitted',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Status',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Actions',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ],
                                            rows: List.generate(visible.length,
                                                (i) {
                                              final data = visible[i];
                                              final blotter = data['blotter'];
                                              final isEven = i % 2 == 0;

                                              return DataRow(
                                                color:
                                                    MaterialStateProperty.all(
                                                        isEven
                                                            ? Color(0xFFF8F8FA)
                                                            : Colors.white),
                                                cells: [
                                                  DataCell(Text(
                                                      blotter['requestId'] ??
                                                          'N/A',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .deepPurple
                                                              .shade700))),
                                                  DataCell(Text(
                                                      blotter['idNumber'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      data['submittedBy'] ??
                                                          'Unknown',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .w600))),
                                                  DataCell(Text(
                                                      data['submitterPurok'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      blotter['tagBlotter'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      blotter['ginBlotter'] ??
                                                          'N/A')),
                                                  DataCell(Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                          blotter['what'] ??
                                                              'N/A',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2))),
                                                  DataCell(Text(
                                                      blotter['when'] ?? 'N/A',
                                                      style: TextStyle(
                                                          fontSize: 12))),
                                                  DataCell(Text(
                                                      blotter['where'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      blotter['dateSubmitted'] ??
                                                          'N/A',
                                                      style: TextStyle(
                                                          fontSize: 12))),
                                                  DataCell(
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: getStatusColor(
                                                                blotter['status'] ??
                                                                    '')
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: getStatusColor(
                                                                blotter['status'] ??
                                                                    ''),
                                                            width: 1),
                                                      ),
                                                      child: Text(
                                                        (blotter['status'] ??
                                                                'PENDING')
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            color: getStatusColor(
                                                                blotter['status'] ??
                                                                    ''),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.visibility,
                                                              color:
                                                                  Colors.blue),
                                                          tooltip:
                                                              'View Details',
                                                          onPressed: () =>
                                                              _showDetailsDialog(
                                                                  data),
                                                        ),
                                                        if (blotter['status'] ==
                                                            'pending')
                                                          PopupMenuButton<
                                                              String>(
                                                            icon: Icon(
                                                                Icons.more_vert,
                                                                color: Colors
                                                                    .grey),
                                                            tooltip:
                                                                'Update Status',
                                                            onSelected: (status) =>
                                                                _updateStatus(
                                                                    data[
                                                                        'docId'],
                                                                    status),
                                                            itemBuilder:
                                                                (context) => [
                                                              PopupMenuItem(
                                                                  value:
                                                                      'approved',
                                                                  child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .check_circle,
                                                                            color:
                                                                                Colors.green,
                                                                            size: 20),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                            'Approve')
                                                                      ])),
                                                              PopupMenuItem(
                                                                  value:
                                                                      'rejected',
                                                                  child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .cancel,
                                                                            color:
                                                                                Colors.red,
                                                                            size: 20),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                            'Reject')
                                                                      ])),
                                                            ],
                                                          ),
                                                      ],
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
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Showing ${filtered.isEmpty ? 0 : 1} to ${visible.length} of ${filtered.length} entries',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: null,
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            side: BorderSide(
                                                color: Colors.grey.shade300)),
                                        child: Text('Previous'),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text('1',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: null,
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            side: BorderSide(
                                                color: Colors.grey.shade300)),
                                        child: Text('Next'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
