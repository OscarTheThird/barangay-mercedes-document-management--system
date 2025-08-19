import 'package:flutter/material.dart';
import 'widgets/section_card.dart';
import 'widgets/process_steps.dart';

class BarangayBlotterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barangay Blotter'),
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

  // Process steps replaced by shared widget

  Widget _buildFormCard(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          SizedBox(height: 24),
          _buildTextField('Blotter Entry No.', Icons.confirmation_number),
          SizedBox(height: 20),
          _sectionTitle('WHO/HINO:'),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Tag-blotter (Name)', Icons.person),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Address', Icons.home),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Gin-blotter (Name)', Icons.person_outline),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Address', Icons.home_outlined),
              ),
            ],
          ),
          SizedBox(height: 20),
          _sectionTitle('WHAT/ANU AN NAHITABO?'),
          SizedBox(height: 8),
          _buildTextField('Describe what happened', Icons.event_note, maxLines: 3),
          SizedBox(height: 20),
          _sectionTitle('WHEN/KAKANU NAHITABO?'),
          SizedBox(height: 8),
          _buildTextField('Date and Time of Incident', Icons.access_time),
          SizedBox(height: 20),
          _sectionTitle('WHERE/DIIN NAHITABO?'),
          SizedBox(height: 8),
          _buildTextField('Location of Incident', Icons.location_on),
          SizedBox(height: 20),
          _sectionTitle('WHY/KAY ANU NAHITABO?'),
          SizedBox(height: 8),
          _buildTextField('Reason for Incident', Icons.help_outline),
          SizedBox(height: 20),
          _sectionTitle('HOW/PAANO NAHITABO?'),
          SizedBox(height: 8),
          _buildTextField('How did it happen?', Icons.question_answer),
          SizedBox(height: 20),
          _sectionTitle('DISPOSITION OF THE CASE / ANU NGA KLASE AN KASO:'),
          SizedBox(height: 8),
          _buildTextField('Case Disposition/Type', Icons.assignment_turned_in),
          SizedBox(height: 28),
          Divider(thickness: 1.2),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Application submitted!')),
                );
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
              child: Row(
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
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple.shade800,
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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
