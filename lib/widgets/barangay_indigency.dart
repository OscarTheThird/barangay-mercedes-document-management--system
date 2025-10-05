import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'indigency_pdf.dart';

class BarangayIndigency extends StatefulWidget {
  const BarangayIndigency({super.key});

  @override
  State<BarangayIndigency> createState() => _BarangayIndigencyState();
}

class _BarangayIndigencyState extends State<BarangayIndigency> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _purokController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  void _showCertificate() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _purokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CertificateDialog(
        name: _nameController.text,
        age: _ageController.text,
        address: _addressController.text,
        purok: _purokController.text,
        purpose: _purposeController.text,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _purokController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate of Indigency'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purokController,
              decoration: const InputDecoration(
                labelText: 'Purok',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Complete Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCertificate,
              icon: const Icon(Icons.visibility),
              label: const Text('Generate Certificate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateDialog extends StatefulWidget {
  final String name;
  final String age;
  final String address;
  final String purok;
  final String purpose;

  const CertificateDialog({
    super.key,
    required this.name,
    required this.age,
    required this.address,
    required this.purok,
    required this.purpose,
  });

  @override
  State<CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<CertificateDialog> {
  bool _isGenerating = false;
  String _punongBarangayName = '';

// Adjusted to match reference image - bigger logo, closer to text
static const double logoSize = 95.0;        // Increased size
static const double logoSpacing = 12.0;     // Space between logo and text
static const double logoRightMargin = 107.0; // Right margin to keep text centered

  @override
  void initState() {
    super.initState();
    _loadPunongBarangay();
  }

  Future<void> _loadPunongBarangay() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('barangay_officials')
          .doc('Barangay Chairman')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _punongBarangayName = doc.data()?['name'] ?? 'HON. JUAN DELA CRUZ';
        });
      }
    } catch (e) {
      debugPrint('Error loading Punong Barangay: $e');
      if (mounted) {
        setState(() {
          _punongBarangayName = 'HON. JUAN DELA CRUZ';
        });
      }
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      
      // Check if word is a suffix like Jr., Sr., II, III, IV, V
      final lowerWord = word.toLowerCase();
      if (lowerWord == 'jr.' || lowerWord == 'jr') {
        return 'Jr.';
      } else if (lowerWord == 'sr.' || lowerWord == 'sr') {
        return 'Sr.';
      } else if (lowerWord == 'ii') {
        return 'II';
      } else if (lowerWord == 'iii') {
        return 'III';
      } else if (lowerWord == 'iv') {
        return 'IV';
      } else if (lowerWord == 'v') {
        return 'V';
      }
      
      // Otherwise, capitalize only first letter
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _downloadPDF() async {
    setState(() => _isGenerating = true);

    try {
      await IndigencyPdfGenerator.generateAndDownload(
        name: widget.name,
        age: widget.age,
        address: widget.address,
        purok: widget.purok,
        purpose: widget.purpose,
        punongBarangayName: _punongBarangayName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _printPDF() async {
    setState(() => _isGenerating = true);

    try {
      await IndigencyPdfGenerator.printDocument(
        name: widget.name,
        age: widget.age,
        address: widget.address,
        purok: widget.purok,
        purpose: widget.purpose,
        punongBarangayName: _punongBarangayName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = DateFormat('MMMM').format(now);
    final year = now.year;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[800],
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Certificate of Indigency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isGenerating)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    IconButton(
                      onPressed: _printPDF,
                      icon: const Icon(Icons.print, color: Colors.white),
                      tooltip: 'Print',
                    ),
                    IconButton(
                      onPressed: _downloadPDF,
                      icon: const Icon(Icons.download, color: Colors.white),
                      tooltip: 'Download PDF',
                    ),
                  ],
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(72),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/mercedeslogo.png',
                            width: logoSize,
                            height: logoSize,
                          ),
                          SizedBox(width: logoSpacing),
                          Expanded(
                            child: Column(
                              children: const [
                                Text(
                                  'Republic of the Philippines',
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Province of Samar',
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Catbalogan City',
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '-oOo-',
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: logoRightMargin),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'OFFICE OF THE BARANGAY CHAIRMAN',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'CERTIFICATE OF INDIGENCY',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TO WHOM IT MAY CONCERN:',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 14,
                            color: Colors.black,
                            height: 2.0,
                          ),
                          children: [
                            const TextSpan(text: '          This is to certify that '),
                            TextSpan(
                              text: _toTitleCase(widget.name),
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ', of legal age, Filipino Citizen, is a resident of this barangay, known to me as having inadequate income and found to be indigent.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        '          This certification is issued upon request of the interested party for whatever legal purpose this may serve.',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: '          Issued this '),
                            TextSpan(
                              text: day,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' day of '),
                            TextSpan(
                              text: month,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ', '),
                            TextSpan(
                              text: year.toString(),
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' at Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Container(
                              width: 250,
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              child: Text(
                                _punongBarangayName,
                                style: const TextStyle(
                                  fontFamily: 'Times New Roman',
                                  fontSize: 14,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Punong Barangay',
                              style: TextStyle(
                                fontFamily: 'Times New Roman',
                                fontSize: 14,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}