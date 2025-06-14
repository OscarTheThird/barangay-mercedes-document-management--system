// File: lib/residency_certificate.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResidencyCertificatePage extends StatefulWidget {
  @override
  _ResidencyCertificatePageState createState() => _ResidencyCertificatePageState();
}

class _ResidencyCertificatePageState extends State<ResidencyCertificatePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Form Controllers
  final TextEditingController _residentIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _lengthOfResidencyController = TextEditingController();
  final TextEditingController _previousAddressController = TextEditingController();
  
  bool _isSubmitting = false;
  int _currentStep = 0;
  String _selectedCivilStatus = 'Single';
  String _selectedResidencyType = 'Permanent';
  final List<String> _civilStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final List<String> _residencyTypeOptions = ['Permanent', 'Temporary', 'Boarder'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _residentIdController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _lengthOfResidencyController.dispose();
    _previousAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Certificate of Residency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEAE6FA),
              Color(0xFFF3F0FF),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 30),
                  _buildProcessSteps(),
                  SizedBox(height: 30),
                  _buildApplicationForm(),
                  SizedBox(height: 30),
                  _buildImportantNotes(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  Icons.home_work,
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
                      'Certificate of Residency Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    Text(
                      'Proof of residence certification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Apply for a certificate of residency online. This document certifies that you are a bona fide resident of the barangay.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.deepPurple.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessSteps() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certificate Process',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          SizedBox(height: 16),
          _buildProcessStep(
            1,
            'Submit Application',
            'Complete the residency certificate form with residence details',
            Icons.edit_document,
            _currentStep >= 0,
          ),
          _buildProcessStep(
            2,
            'Residency Verification',
            'Barangay officials will verify your residence status',
            Icons.location_searching,
            _currentStep >= 1,
          ),
          _buildProcessStep(
            3,
            'Review & Approval',
            'Application will be reviewed and approved by authorities',
            Icons.verified,
            _currentStep >= 2,
          ),
          _buildProcessStep(
            4,
            'Collection',
            'Visit the barangay office to collect your certificate',
            Icons.assignment_turned_in,
            _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String description, IconData icon, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.deepPurple : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$step. $title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.deepPurple.shade800 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal & Residency Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            SizedBox(height: 24),
            
            // Resident ID
            _buildTextFormField(
              controller: _residentIdController,
              label: 'Resident ID Number',
              hint: 'Enter your resident ID number',
              icon: Icons.badge,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your resident ID number';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Full Name
            _buildTextFormField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your complete name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Birth Date
            _buildTextFormField(
              controller: _birthDateController,
              label: 'Date of Birth',
              hint: 'MM/DD/YYYY',
              icon: Icons.calendar_today,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your birth date';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Birth Place
            _buildTextFormField(
              controller: _birthPlaceController,
              label: 'Place of Birth',
              hint: 'Enter your place of birth',
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your place of birth';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Civil Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCivilStatus,
              decoration: InputDecoration(
                labelText: 'Civil Status',
                prefixIcon: Icon(Icons.family_restroom, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                labelStyle: TextStyle(color: Colors.deepPurple.shade700),
              ),
              items: _civilStatusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCivilStatus = newValue!;
                });
              },
            ),
            
            SizedBox(height: 16),
            
            // Current Address
            _buildTextFormField(
              controller: _addressController,
              label: 'Current Address',
              hint: 'Enter your current complete address',
              icon: Icons.home,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current address';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Residency Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedResidencyType,
              decoration: InputDecoration(
                labelText: 'Residency Type',
                prefixIcon: Icon(Icons.house, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                labelStyle: TextStyle(color: Colors.deepPurple.shade700),
              ),
              items: _residencyTypeOptions.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedResidencyType = newValue!;
                });
              },
            ),
            
            SizedBox(height: 16),
            
            // Length of Residency
            _buildTextFormField(
              controller: _lengthOfResidencyController,
              label: 'Length of Residency',
              hint: 'e.g., 5 years, 2 months',
              icon: Icons.access_time,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter length of residency';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Previous Address (if applicable)
            _buildTextFormField(
              controller: _previousAddressController,
              label: 'Previous Address',
              hint: 'Enter previous address (if applicable)',
              icon: Icons.location_history,
              maxLines: 2,
            ),
            
            SizedBox(height: 16),
            
            // Contact Number
            _buildTextFormField(
              controller: _contactController,
              label: 'Contact Number',
              hint: 'Enter your mobile number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your contact number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Email
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Purpose
            _buildTextFormField(
              controller: _purposeController,
              label: 'Purpose',
              hint: 'State the purpose of this certificate',
              icon: Icons.assignment,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the purpose of this certificate';
                }
                return null;
              },
            ),
            
            SizedBox(height: 32),
            
            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.deepPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    'Submitting Application...',
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
                    'Submit Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImportantNotes() {
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
                'Important Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildNoteItem('Processing time: 3-5 business days'),
          _buildNoteItem('Residency verification will be conducted'),
          _buildNoteItem('SMS and email notifications will be sent'),
          _buildNoteItem('Bring valid government ID for pickup'),
          _buildNoteItem('Certificate fee: ₱30 (payable upon pickup)'),
          _buildNoteItem('Valid for 1 year from date of issue'),
          _buildNoteItem('Office hours: Monday-Friday, 8:00 AM - 5:00 PM'),
          _buildNoteItem('Two witnesses may be required for verification'),
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

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isSubmitting = false;
      });

      // Show success dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Application Submitted!',
                style: TextStyle(
                  color: Colors.deepPurple.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your certificate of residency application has been successfully submitted.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reference Number:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    Text(
                      'RES${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'What happens next:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text('• Residency verification will be conducted'),
              Text('• Processing will take 3-5 business days'),
              Text('• You will receive notifications via SMS and email'),
              Text('• Visit the barangay office for pickup when notified'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to services
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}