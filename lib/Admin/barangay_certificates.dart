import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BarangayCertificatesPage extends StatefulWidget {
  const BarangayCertificatesPage({super.key});

  @override
  State<BarangayCertificatesPage> createState() =>
      _BarangayCertificatesPageState();
}

class _BarangayCertificatesPageState extends State<BarangayCertificatesPage> {
  int _rowsPerPage = 10;
  String _search = '';
  String _statusFilter = 'All';
  bool _isRefreshing = false;

  final List<String> _statusOptions = [
    'All',
    'pending',
    'approved',
    'rejected'
  ];

  // Helper function to get resident by ID number
  Future<Map<String, dynamic>?> getResidentByIdNumber(String idNumber) async {
    List<String> puroks = [
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

    for (String purok in puroks) {
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
        debugPrint('Error searching in $purok: $e');
      }
    }
    return null;
  }

  // Format timestamp to readable date
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  // Build full name from resident data
  String buildFullName(Map<String, dynamic>? resident) {
    if (resident == null) return 'Unknown Resident';

    final firstname = resident['firstname'] ?? '';
    final middlename = resident['middlename'] ?? '';
    final lastname = resident['lastname'] ?? '';

    String fullName = firstname;
    if (middlename.isNotEmpty) fullName += ' $middlename';
    if (lastname.isNotEmpty) fullName += ' $lastname';

    return fullName.trim().isEmpty ? 'Unknown' : fullName.trim();
  }

  // Get status color
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

  // Pull to refresh
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Center(
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Certification Requests',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Export feature coming soon')),
                          );
                        },
                        icon: Icon(Icons.file_download, color: Colors.white),
                        label: Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Controls
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
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text('$e')))
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
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                          ),
                          onChanged: (value) => setState(() => _search = value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Data Table with StreamBuilder
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('certification')
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
                                Text(
                                  'Error loading data',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading certification requests...'),
                              ],
                            ),
                          );
                        }

                        final requests = snapshot.data!.docs;

                        if (requests.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No certification requests found',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }

                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: _buildTableData(requests),
                          builder: (context, dataSnapshot) {
                            if (dataSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingShimmer();
                            }

                            if (dataSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error processing data: ${dataSnapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            final allData = dataSnapshot.data ?? [];
                            final filtered = _filterData(allData);
                            final visible =
                                filtered.take(_rowsPerPage).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No results found',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters',
                                      style: TextStyle(color: Colors.grey),
                                    ),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                              columnSpacing: 20,
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                      Color(0xFFF6F6FA)),
                                              dividerThickness: 0.5,
                                              columns: const [
                                                DataColumn(
                                                  label: Text('Request ID',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('ID Number',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Full Name',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Purok',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Contact',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Purpose',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Date Submitted',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Status',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                DataColumn(
                                                  label: Text('Action',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                              rows: List.generate(
                                                  visible.length, (i) {
                                                final data = visible[i];
                                                final isEven = i % 2 == 0;

                                                return DataRow(
                                                  color:
                                                      MaterialStateProperty.all(
                                                    isEven
                                                        ? Color(0xFFF8F8FA)
                                                        : Colors.white,
                                                  ),
                                                  cells: [
                                                    DataCell(Text(
                                                      data['requestId'] ??
                                                          'N/A',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .deepPurple
                                                              .shade700),
                                                    )),
                                                    DataCell(Text(
                                                        data['idNumber'] ??
                                                            'N/A')),
                                                    DataCell(
                                                      Text(
                                                        data['fullName'] ??
                                                            'Unknown',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    DataCell(Text(
                                                        data['purok'] ??
                                                            'N/A')),
                                                    DataCell(Text(
                                                        data['contact'] ??
                                                            'N/A')),
                                                    DataCell(
                                                      Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: 200),
                                                        child: Text(
                                                          data['purpose'] ??
                                                              'N/A',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        data['dateSubmitted'] ??
                                                            'N/A',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: getStatusColor(
                                                                  data['status'] ??
                                                                      '')
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: getStatusColor(
                                                                data['status'] ??
                                                                    ''),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          (data['status'] ?? '')
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            color: getStatusColor(
                                                                data['status'] ??
                                                                    ''),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11,
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
                                                                Icons
                                                                    .visibility,
                                                                color: Colors
                                                                    .blue),
                                                            tooltip: 'View',
                                                            onPressed: () {
                                                              _showRequestDetails(
                                                                  context,
                                                                  data);
                                                            },
                                                          ),
                                                          if (data['status'] ==
                                                              'pending')
                                                            PopupMenuButton<
                                                                String>(
                                                              icon: Icon(
                                                                  Icons
                                                                      .more_vert,
                                                                  color: Colors
                                                                      .grey),
                                                              onSelected:
                                                                  (value) {
                                                                _updateStatus(
                                                                    data[
                                                                        'docId'],
                                                                    value);
                                                              },
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
                                                                          color: Colors
                                                                              .green,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                          'Approve'),
                                                                    ],
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value:
                                                                      'rejected',
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color: Colors
                                                                              .red,
                                                                          size:
                                                                              20),
                                                                      SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                          'Reject'),
                                                                    ],
                                                                  ),
                                                                ),
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
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
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
      ),
    );
  }

  // Build loading shimmer effect
  Widget _buildLoadingShimmer() {
    return Center(
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
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Color(0xFFF6F6FA)),
              columns: const [
                DataColumn(
                    label: Text('Request ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('ID Number',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Full Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Purok',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Contact',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Purpose',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Date Submitted',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(
                5,
                (i) => DataRow(
                  color: MaterialStateProperty.all(
                      i % 2 == 0 ? Color(0xFFF8F8FA) : Colors.white),
                  cells: List.generate(
                    9,
                    (j) => DataCell(
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build table data by looking up residents
  Future<List<Map<String, dynamic>>> _buildTableData(
      List<QueryDocumentSnapshot> requests) async {
    List<Map<String, dynamic>> tableData = [];

    for (var doc in requests) {
      final data = doc.data() as Map<String, dynamic>;
      final idNumber = data['idNumber'] ?? '';

      // Lookup resident info
      final resident = await getResidentByIdNumber(idNumber);

      tableData.add({
        'docId': doc.id,
        'requestId': data['requestId'] ?? doc.id,
        'idNumber': idNumber,
        'fullName': buildFullName(resident),
        'purok': resident?['purok'] ?? 'N/A',
        'contact': resident?['contact'] ??
            resident?['contactNumber'] ??
            resident?['phone'] ??
            'N/A',
        'purpose': data['purpose'] ?? 'N/A',
        'dateSubmitted': formatDate(data['timestamp']),
        'status': data['status'] ?? 'pending',
        'timestamp': data['timestamp'],
        'userId': data['userId'],
        'residentData': resident,
      });
    }

    return tableData;
  }

  // Filter data based on search and status
  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    return data.where((item) {
      // Status filter
      if (_statusFilter != 'All' &&
          item['status'].toString().toLowerCase() !=
              _statusFilter.toLowerCase()) {
        return false;
      }

      // Search filter
      if (_search.isNotEmpty) {
        final searchLower = _search.toLowerCase();
        final idMatch =
            item['idNumber'].toString().toLowerCase().contains(searchLower);
        final nameMatch =
            item['fullName'].toString().toLowerCase().contains(searchLower);
        final requestIdMatch =
            item['requestId'].toString().toLowerCase().contains(searchLower);

        return idMatch || nameMatch || requestIdMatch;
      }

      return true;
    }).toList();
  }

  // Update request status
  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('certification')
          .doc(docId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show request details dialog
  void _showRequestDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Certification Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Request ID', data['requestId']),
              Divider(),
              _buildDetailRow('ID Number', data['idNumber']),
              _buildDetailRow('Full Name', data['fullName']),
              _buildDetailRow('Purok', data['purok']),
              _buildDetailRow('Contact', data['contact']),
              Divider(),
              _buildDetailRow('Purpose', data['purpose']),
              _buildDetailRow('Date Submitted', data['dateSubmitted']),
              _buildDetailRow(
                  'Status', data['status'].toString().toUpperCase()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
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
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
