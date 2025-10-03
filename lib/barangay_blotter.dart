import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/section_card.dart';
import 'widgets/process_steps.dart';

class BarangayBlotterPage extends StatefulWidget {
  @override
  _BarangayBlotterPageState createState() => _BarangayBlotterPageState();
}

class _BarangayBlotterPageState extends State<BarangayBlotterPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isSubmitting = false;

  // TextEditingControllers for all form fields
  final _idNumberController = TextEditingController(); // Updated: ID Number controller
  final _tagBlotterController = TextEditingController();
  final _tagBlotterAddressController = TextEditingController();
  final _ginBlotterController = TextEditingController();
  final _ginBlotterAddressController = TextEditingController();
  final _whatController = TextEditingController();
  final _whenController = TextEditingController();
  final _whereController = TextEditingController();
  final _whyController = TextEditingController();
  final _howController = TextEditingController();
  final _dispositionController = TextEditingController();

  // Selected date and time
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    // Dispose all controllers
    _idNumberController.dispose(); // Updated: Dispose ID Number controller
    _tagBlotterController.dispose();
    _tagBlotterAddressController.dispose();
    _ginBlotterController.dispose();
    _ginBlotterAddressController.dispose();
    _whatController.dispose();
    _whenController.dispose();
    _whereController.dispose();
    _whyController.dispose();
    _howController.dispose();
    _dispositionController.dispose();
    super.dispose();
  }

  // Method to submit blotter to Firestore
  Future<void> _submitBlotter() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to submit a blotter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Generate requestId
      final requestId = 'BLOT${DateTime.now().millisecondsSinceEpoch}';

      // Create document data
      final blotterData = {
        'requestId': requestId,
        'idNumber': _idNumberController.text.trim(), // Updated: Using idNumber
        'tagBlotter': _tagBlotterController.text.trim(),
        'tagBlotterAddress': _tagBlotterAddressController.text.trim(),
        'ginBlotter': _ginBlotterController.text.trim(),
        'ginBlotterAddress': _ginBlotterAddressController.text.trim(),
        'what': _whatController.text.trim(),
        'when': _whenController.text.trim(),
        'where': _whereController.text.trim(),
        'why': _whyController.text.trim(),
        'how': _howController.text.trim(),
        'disposition': _dispositionController.text.trim(),
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      // Submit to Firestore
      await FirebaseFirestore.instance
          .collection('barangay_blotter')
          .doc(requestId)
          .set(blotterData);

      // Clear form
      _clearForm();

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(requestId);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting blotter: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Method to show success dialog
  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF3F0FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),
                // Title
                Text(
                  'Blotter Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                SizedBox(height: 16),
                // Description
                Text(
                  'Your barangay blotter entry has been successfully submitted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 20),
                // Reference Number Container
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Reference Number:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      SelectableText(
                        requestId,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // What happens next section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens next:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDialogInfoItem('Your report will be reviewed by barangay officials'),
                      _buildDialogInfoItem('Investigation will take 3-5 business days'),
                      _buildDialogInfoItem('You will receive notifications via SMS and email'),
                      _buildDialogInfoItem('Visit the barangay office if mediation is required'),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.amber.shade900,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to clear form
  void _clearForm() {
    _idNumberController.clear(); // Updated: Clear ID Number controller
    _tagBlotterController.clear();
    _tagBlotterAddressController.clear();
    _ginBlotterController.clear();
    _ginBlotterAddressController.clear();
    _whatController.clear();
    _whenController.clear();
    _whereController.clear();
    _whyController.clear();
    _howController.clear();
    _dispositionController.clear();
    setState(() {
      _selectedDateTime = null;
    });
  }

  // Method to pick date and time
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.deepPurple.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                onSurface: Colors.deepPurple.shade700,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _whenController.text =
              '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')} '
                  '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Barangay Blotter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAE6FA), Color(0xFFF3F0FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                SizedBox(height: 30),
                SectionCard(
                  child: ProcessSteps(
                    heading: 'Blotter Process',
                    steps: const [
                      ProcessStepData(step: 1, title: 'Submit Blotter', description: 'Fill out the form below and submit your blotter entry', icon: Icons.edit_document, isActive: true),
                      ProcessStepData(step: 2, title: 'Investigation', description: 'Barangay officials will review and investigate the incident', icon: Icons.hourglass_empty),
                      ProcessStepData(step: 3, title: 'Resolution', description: 'Resolution or mediation will be conducted if necessary', icon: Icons.gavel),
                      ProcessStepData(step: 4, title: 'Archiving', description: 'The blotter record will be archived for official records', icon: Icons.archive),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                _buildFormCard(context),
                SizedBox(height: 30),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.report,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Republic of the Philippines',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
                    ),
                    Text(
                      'Province of Samar',
                      style: TextStyle(fontSize: 15, color: Colors.deepPurple.shade600),
                    ),
                    Text(
                      'Catbalogan City',
                      style: TextStyle(fontSize: 15, color: Colors.deepPurple.shade600),
                    ),
                    Text(
                      'Barangay Mercedes',
                      style: TextStyle(fontSize: 15, color: Colors.deepPurple.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'OFFICE OF THE LUPONG TAGAPAMAYAPA',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          SizedBox(height: 8),
          Text(
            'BLOTTER',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return SectionCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blotter Entry Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField( // Updated: The field now asks for ID Number
              'ID Number',
              Icons.credit_card,
              _idNumberController,
              required: true,
            ),
            SizedBox(height: 24),
            Text(
              'Incident Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            SizedBox(height: 16),
            _sectionTitle('WHO/HINO:'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Tag-blotter (Name)',
                    Icons.person,
                    _tagBlotterController,
                    required: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    'Address',
                    Icons.home,
                    _tagBlotterAddressController,
                    required: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Gin-blotter (Name)',
                    Icons.person_outline,
                    _ginBlotterController,
                    required: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    'Address',
                    Icons.home_outlined,
                    _ginBlotterAddressController,
                    required: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _sectionTitle('WHAT/ANU AN NAHITABO?'),
            SizedBox(height: 8),
            _buildTextField(
              'Describe what happened',
              Icons.event_note,
              _whatController,
              maxLines: 3,
              required: true,
            ),
            SizedBox(height: 20),
            _sectionTitle('WHEN/KAKANU NAHITABO?'),
            SizedBox(height: 8),
            TextFormField(
              controller: _whenController,
              readOnly: true,
              onTap: _pickDateTime,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Date and Time of Incident *',
                prefixIcon: Icon(Icons.access_time, color: Colors.deepPurple),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                labelStyle: TextStyle(color: Colors.deepPurple.shade700),
                hintText: 'Tap to select date and time',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: 20),
            _sectionTitle('WHERE/DIIN NAHITABO?'),
            SizedBox(height: 8),
            _buildTextField(
              'Location of Incident',
              Icons.location_on,
              _whereController,
              required: true,
            ),
            SizedBox(height: 20),
            _sectionTitle('WHY/KAY ANU NAHITABO?'),
            SizedBox(height: 8),
            _buildTextField(
              'Reason for Incident',
              Icons.help_outline,
              _whyController,
            ),
            SizedBox(height: 20),
            _sectionTitle('HOW/PAANO NAHITABO?'),
            SizedBox(height: 8),
            _buildTextField(
              'How did it happen?',
              Icons.question_answer,
              _howController,
            ),
            SizedBox(height: 20),
            _sectionTitle('DISPOSITION OF THE CASE / ANU NGA KLASE AN KASO:'),
            SizedBox(height: 8),
            _buildTextField(
              'Case Disposition/Type',
              Icons.assignment_turned_in,
              _dispositionController,
            ),
            SizedBox(height: 28),
            Divider(thickness: 1.2),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBlotter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Blotter Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple.shade700,
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        int maxLines = 1,
        bool required = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: required
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.deepPurple.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildNoteItem('All information must be accurate and truthful.'),
          _buildNoteItem('Blotter entries are official records.'),
          _buildNoteItem('Contact the barangay office for corrections.'),
          _buildNoteItem('Bring valid ID for any in-person follow-up.'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.amber.shade700, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.amber.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}