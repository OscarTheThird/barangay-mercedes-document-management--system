import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<String> notes;

  const InfoCard({
    super.key,
    required this.title,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
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
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...notes.map((t) => _Note(text: t)).toList(),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note({required this.text});

  @override
  Widget build(BuildContext context) {
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


