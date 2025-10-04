import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BarangayComplaintTablePage extends StatefulWidget {
  const BarangayComplaintTablePage({super.key});

  @override
  State<BarangayComplaintTablePage> createState() => _BarangayComplaintTablePageState();
}

class _BarangayComplaintTablePageState extends State<BarangayComplaintTablePage> {
  int _rowsPerPage = 10;
  String _search = '';
  String _statusFilter = 'All';

  final List<String> _statusOptions = ['All', 'pending', 'approved', 'rejected'];

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
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
          .collection('complaints')
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

  void _showDetailsDialog(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.report_problem, color: Colors.red),
            SizedBox(width: 8),
            Text('Complaint Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Request ID', complaint['requestId'] ?? 'N/A'),
              Divider(height: 24),
              _buildDetailRow('Complainant', complaint['complainant'] ?? 'N/A'),
              _buildDetailRow('Respondent', complaint['respondent'] ?? 'N/A'),
              Divider(height: 24),
              Text('Complaint Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  complaint['complaintDetails'] ?? 'No details provided',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Divider(height: 24),
              _buildDetailRow('Date Submitted', complaint['dateSubmitted'] ?? 'N/A'),
              _buildDetailRow('Status', (complaint['status'] ?? 'pending').toString().toUpperCase()),
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
            width: 130,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildTableData(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'docId': doc.id,
        'requestId': data['requestId'] ?? doc.id,
        'complainant': data['complainant'] ?? 'N/A',
        'respondent': data['respondent'] ?? 'N/A',
        'complaintDetails': data['complaintDetails'] ?? 'No details provided',
        'dateSubmitted': formatDate(data['timestamp']),
        'status': data['status'] ?? 'pending',
        'timestamp': data['timestamp'],
        'userId': data['userId'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    return data.where((item) {
      // Status filter
      if (_statusFilter != 'All' &&
          item['status'].toString().toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }

      // Search filter
      if (_search.isNotEmpty) {
        final searchLower = _search.toLowerCase();
        final requestIdMatch = item['requestId'].toString().toLowerCase().contains(searchLower);
        final complainantMatch = item['complainant'].toString().toLowerCase().contains(searchLower);
        final respondentMatch = item['respondent'].toString().toLowerCase().contains(searchLower);

        return requestIdMatch || complainantMatch || respondentMatch;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Barangay Complaint', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export CSV feature coming soon')),
                        );
                      },
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
                        SizedBox(width: 24),
                        Text('Status:'),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _statusFilter,
                          items: _statusOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                        .collection('complaints')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Error loading data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(snapshot.error.toString(), style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
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
                              Text('Loading complaints...'),
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
                              Text('No complaints found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }

                      final allData = _buildTableData(snapshot.data!.docs);
                      final filtered = _filterData(allData);
                      final visible = filtered.take(_rowsPerPage).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Try adjusting your filters', style: TextStyle(color: Colors.grey)),
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
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 1200),
                                      child: DataTable(
                                        columnSpacing: 20,
                                        headingRowColor: MaterialStateProperty.all(Color(0xFFF6F6FA)),
                                        dividerThickness: 0.5,
                                        columns: const [
                                          DataColumn(label: Text('Request ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Complainant', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Respondent', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Complaint Details', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Date Submitted', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                        rows: List.generate(visible.length, (i) {
                                          final data = visible[i];
                                          final isEven = i % 2 == 0;

                                          return DataRow(
                                            color: MaterialStateProperty.all(isEven ? Color(0xFFF8F8FA) : Colors.white),
                                            cells: [
                                              DataCell(
                                                Text(
                                                  data['requestId'] ?? 'N/A',
                                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  data['complainant'] ?? 'N/A',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              DataCell(Text(data['respondent'] ?? 'N/A')),
                                              DataCell(
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: 250),
                                                  child: Text(
                                                    data['complaintDetails'] ?? 'No details',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  data['dateSubmitted'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(data['status'] ?? '').withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: getStatusColor(data['status'] ?? ''),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    (data['status'] ?? 'PENDING').toUpperCase(),
                                                    style: TextStyle(
                                                      color: getStatusColor(data['status'] ?? ''),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.visibility, color: Colors.blue),
                                                      tooltip: 'View Details',
                                                      onPressed: () => _showDetailsDialog(data),
                                                    ),
                                                    if (data['status'] == 'pending')
                                                      PopupMenuButton<String>(
                                                        icon: Icon(Icons.more_vert, color: Colors.grey),
                                                        tooltip: 'Update Status',
                                                        onSelected: (status) => _updateStatus(data['docId'], status),
                                                        itemBuilder: (context) => [
                                                          PopupMenuItem(
                                                            value: 'approved',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                                SizedBox(width: 8),
                                                                Text('Approve'),
                                                              ],
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'rejected',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.cancel, color: Colors.red, size: 20),
                                                                SizedBox(width: 8),
                                                                Text('Reject'),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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