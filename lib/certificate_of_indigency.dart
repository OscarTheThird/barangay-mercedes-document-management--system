import 'package:flutter/material.dart';
import 'widgets/process_steps.dart';
import 'widgets/section_card.dart';

class CertificateOfIndigencyPage extends StatefulWidget {
  @override
  _CertificateOfIndigencyPageState createState() => _CertificateOfIndigencyPageState();
}

class _CertificateOfIndigencyPageState extends State<CertificateOfIndigencyPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Certificate of Indigency',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
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
                      heading: 'Indigency Certificate Process',
                      steps: const [
                        ProcessStepData(step: 1, title: 'Submit Application', description: 'Complete the indigency certificate application form with your details', icon: Icons.edit_document, isActive: true),
                        ProcessStepData(step: 2, title: 'Review & Approval', description: 'Barangay officials will review and approve your certificate', icon: Icons.verified),
                        ProcessStepData(step: 3, title: 'Collection', description: 'Visit the barangay office to collect your certificate', icon: Icons.assignment_turned_in),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildApplicationForm(),
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
                      'Certificate of Indigency Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    Text(
                      'Digital indigency certificate application',
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
            'Apply for a certificate of indigency online. This certificate is issued upon request for whatever legal purpose it may serve.',
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
              'Indigency Certificate Information',
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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
        onPressed: _isSubmitting ? null : () {
          setState(() {
            _isSubmitting = true;
          });
          // Simulate a delay for submission
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Certificate of Indigency application submitted!')),
            );
          });
        },
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
} 