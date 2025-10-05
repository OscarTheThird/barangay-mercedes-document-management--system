import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'certification_pdf.dart';

class BarangayCertification extends StatefulWidget {
  const BarangayCertification({super.key});

  @override
  State<BarangayCertification> createState() => _BarangayCertificationState();
}

class _BarangayCertificationState extends State<BarangayCertification> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _purokController = TextEditingController();
  String _civilStatus = 'single';

  void _showCertificate() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
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
        civilStatus: _civilStatus,
        purok: _purokController.text,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _purokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barangay Certification'),
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
            DropdownButtonFormField<String>(
              value: _civilStatus,
              decoration: const InputDecoration(
                labelText: 'Civil Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite),
              ),
              items: const [
                DropdownMenuItem(value: 'single', child: Text('Single')),
                DropdownMenuItem(value: 'married', child: Text('Married')),
                DropdownMenuItem(value: 'widow', child: Text('Widow')),
                DropdownMenuItem(value: 'widower', child: Text('Widower')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _civilStatus = value;
                  });
                }
              },
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
  final String civilStatus;
  final String purok;

  const CertificateDialog({
    super.key,
    required this.name,
    required this.age,
    required this.civilStatus,
    required this.purok,
  });

  @override
  State<CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<CertificateDialog> {
  bool _isGenerating = false;
  String _punongBarangayName = '';

  static const double logoSize = 95.0;
  static const double logoSpacing = 12.0;
  static const double logoRightMargin = 107.0;

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
      
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _downloadPDF() async {
    setState(() => _isGenerating = true);

    try {
      await CertificationPdfGenerator.generateAndDownload(
        name: widget.name,
        age: widget.age,
        civilStatus: widget.civilStatus,
        purok: widget.purok,
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
      await CertificationPdfGenerator.printDocument(
        name: widget.name,
        age: widget.age,
        civilStatus: widget.civilStatus,
        purok: widget.purok,
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
                      'Barangay Certification',
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
                        'CERTIFICATION',
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
                            const TextSpan(text: '          This is to CERTIFY that '),
                            TextSpan(
                              text: _toTitleCase(widget.name),
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ', '),
                            TextSpan(
                              text: widget.age,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' years of age, Filipino Citizen, '),
                            TextSpan(
                              text: widget.civilStatus,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and a resident of Purok '),
                            TextSpan(
                              text: widget.purok,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ', Barangay Mercedes, Catbalogan City, Samar, Philippines.'),
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