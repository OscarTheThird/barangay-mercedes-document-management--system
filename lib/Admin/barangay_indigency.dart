import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_management_system/widgets/barangay_indigency.dart';

class BarangayIndigencyTablePage extends StatefulWidget {
  const BarangayIndigencyTablePage({super.key});

  @override
  State<BarangayIndigencyTablePage> createState() =>
      _BarangayIndigencyTablePageState();
}

class _BarangayIndigencyTablePageState
    extends State<BarangayIndigencyTablePage> {
  int _rowsPerPage = 10;
  String _search = '';
  String _statusFilter = 'all';

  final List<String> _puroks = [
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

  Future<void> _updateStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('certificate_of_indigency')
          .doc(requestId)
          .update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

 void _showDetailsDialog(
    Map<String, dynamic> request, Map<String, dynamic>? resident) {
  if (resident == null) {
    // Show error if resident not found
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resident information not found'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Import the CertificateDialog from barangay_indigency.dart
  showDialog(
    context: context,
    builder: (context) => CertificateDialog(
      name: '${resident['firstname'] ?? ''} ${resident['middlename'] ?? ''} ${resident['lastname'] ?? ''}',
      age: resident['age']?.toString() ?? '',
      address: resident['address'] ?? '',
      purok: resident['purok'] ?? '',
      purpose: request['purpose'] ?? '',
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
            width: 120,
            child:
                Text('$label:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
                    Text('Certificate of Indigency',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement CSV export
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
                          items: [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(
                                value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(
                                value: 'approved', child: Text('Approved')),
                            DropdownMenuItem(
                                value: 'rejected', child: Text('Rejected')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _statusFilter = value);
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 220,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
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
                        .collection('certificate_of_indigency')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No requests found'));
                      }

                      final requests = snapshot.data!.docs;

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: Future.wait(
                          requests.map((doc) async {
                            final requestData =
                                doc.data() as Map<String, dynamic>;
                            requestData['docId'] = doc.id;
                            final resident = await getResidentByIdNumber(
                                requestData['idNumber'] ?? '');
                            return {
                              'request': requestData,
                              'resident': resident,
                            };
                          }).toList(),
                        ),
                        builder: (context, dataSnapshot) {
                          if (dataSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!dataSnapshot.hasData) {
                            return Center(
                                child: Text('Loading resident data...'));
                          }

                          var combined = dataSnapshot.data!;

                          // Apply status filter
                          if (_statusFilter != 'all') {
                            combined = combined.where((item) {
                              final status = item['request']['status']
                                      ?.toString()
                                      .toLowerCase() ??
                                  '';
                              return status == _statusFilter;
                            }).toList();
                          }

                          // Apply search filter
                          if (_search.isNotEmpty) {
                            combined = combined.where((item) {
                              final request = item['request'];
                              final resident = item['resident'];

                              final idMatch = (request['idNumber'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(_search.toLowerCase());
                              final requestIdMatch =
                                  (request['requestId'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains(_search.toLowerCase());
                              final purposeMatch = (request['purpose'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(_search.toLowerCase());

                              if (resident != null) {
                                final nameMatch = (resident['firstname'] ?? '')
                                        .toString()
                                        .toLowerCase()
                                        .contains(_search.toLowerCase()) ||
                                    (resident['middlename'] ?? '')
                                        .toString()
                                        .toLowerCase()
                                        .contains(_search.toLowerCase()) ||
                                    (resident['lastname'] ?? '')
                                        .toString()
                                        .toLowerCase()
                                        .contains(_search.toLowerCase());
                                return idMatch ||
                                    requestIdMatch ||
                                    purposeMatch ||
                                    nameMatch;
                              }

                              return idMatch || requestIdMatch || purposeMatch;
                            }).toList();
                          }

                          final visible = combined.take(_rowsPerPage).toList();

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
                                              BoxConstraints(minWidth: 1200),
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
                                                  label: Text('Full Name',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Purok',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Contact',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('Purpose',
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
                                              final item = visible[i];
                                              final request = item['request'];
                                              final resident = item['resident'];
                                              final isEven = i % 2 == 0;

                                              return DataRow(
                                                color:
                                                    MaterialStateProperty.all(
                                                        isEven
                                                            ? Color(0xFFF8F8FA)
                                                            : Colors.white),
                                                cells: [
                                                  DataCell(Text(
                                                      request['requestId'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      request['idNumber'] ??
                                                          'N/A')),
                                                  DataCell(
                                                    Text(
                                                      resident != null
                                                          ? '${resident['firstname'] ?? ''} ${resident['middlename'] ?? ''} ${resident['lastname'] ?? ''}'
                                                          : 'Not Found',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: resident != null
                                                            ? Colors.deepPurple
                                                                .shade900
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text(
                                                      resident?['purok'] ??
                                                          'N/A')),
                                                  DataCell(Text(
                                                      resident?['contact'] ??
                                                          'N/A')),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        request['purpose'] ??
                                                            'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      request['timestamp'] !=
                                                              null
                                                          ? (request['timestamp']
                                                                  as Timestamp)
                                                              .toDate()
                                                              .toString()
                                                              .split(' ')[0]
                                                          : 'N/A',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                            request['status']),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        (request['status'] ??
                                                                'pending')
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
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
                                                                  request,
                                                                  resident),
                                                        ),
                                                        PopupMenuButton<String>(
                                                          icon: Icon(
                                                              Icons.more_vert),
                                                          tooltip:
                                                              'Update Status',
                                                          onSelected: (status) =>
                                                              _updateStatus(
                                                                  request[
                                                                      'docId'],
                                                                  status),
                                                          itemBuilder:
                                                              (context) => [
                                                            PopupMenuItem(
                                                                value:
                                                                    'pending',
                                                                child: Text(
                                                                    'Pending')),
                                                            PopupMenuItem(
                                                                value:
                                                                    'approved',
                                                                child: Text(
                                                                    'Approved')),
                                                            PopupMenuItem(
                                                                value:
                                                                    'rejected',
                                                                child: Text(
                                                                    'Rejected')),
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
                                      'Showing ${combined.isEmpty ? 0 : 1} to ${visible.length} of ${combined.length} entries'),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: null,
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Text('Previous'),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
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
                                              color: Colors.grey.shade300),
                                        ),
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
