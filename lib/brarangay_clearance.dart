import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/process_steps.dart';
import 'widgets/section_card.dart';
import 'widgets/info_card.dart';

class BarangayClearancePage extends StatefulWidget {
  @override
  _BarangayClearancePageState createState() => _BarangayClearancePageState();
}

class _BarangayClearancePageState extends State<BarangayClearancePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _purokController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String _selectedCivilStatus = 'Single';
  final List<String> _civilStatusOptions = ['Single', 'Married', 'Widowed'];

  bool _isSubmitting = false;
  int _currentStep = 0;

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
    _idController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _purokController.dispose();
    _purposeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Barangay Clearance',
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
                  SectionCard(
                    child: ProcessSteps(
                      heading: 'Clearance Process',
                      steps: [
                        ProcessStepData(step: 1, title: 'Submit Application', description: 'Complete the clearance application form with personal details', icon: Icons.edit_document, isActive: _currentStep >= 0),
                        ProcessStepData(step: 2, title: 'Background Check', description: 'Barangay office will conduct background verification', icon: Icons.search, isActive: _currentStep >= 1),
                        ProcessStepData(step: 3, title: 'Review & Approval', description: 'Barangay officials will review and approve your clearance', icon: Icons.verified, isActive: _currentStep >= 2),
                        ProcessStepData(step: 4, title: 'Collection', description: 'Visit the barangay office to collect your clearance', icon: Icons.assignment_turned_in, isActive: _currentStep >= 3),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildApplicationForm(),
                  SizedBox(height: 30),
                  InfoCard(
                    title: 'Important Information',
                    notes: const [
                      'Processing time: 5-7 business days',
                      'Background verification will be conducted',
                      'SMS and email notifications will be sent',
                      'Bring valid government ID for pickup',
                      'Clearance fee: ₱50 (payable upon pickup)',
                      'Valid for 6 months from date of issue',
                      'Office hours: Monday-Friday, 8:00 AM - 5:00 PM',
                    ],
                  ),
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
                  Icons.verified_user,
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
                      'Barangay Clearance Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    Text(
                      'Digital clearance application',
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
            'Apply for a barangay clearance certificate online. This clearance certifies your good moral character and standing in the community.',
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

  // Process steps replaced by shared widget

  Widget _buildApplicationForm() {
    return SectionCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            SizedBox(height: 24),
            // ID
            _buildTextFormField(
              controller: _idController,
              label: 'ID',
              hint: 'Enter your ID number',
              icon: Icons.badge,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your ID number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Purpose
            _buildTextFormField(
              controller: _purposeController,
              label: 'Purpose',
              hint: 'State the purpose of this clearance',
              icon: Icons.assignment,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the purpose of this clearance';
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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

  // Notes replaced with shared InfoCard

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
                'Your barangay clearance application has been successfully submitted.',
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
                      'CLR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
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
              Text('• Background verification will be conducted'),
              Text('• Processing will take 5-7 business days'),
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