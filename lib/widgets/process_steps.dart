import 'package:flutter/material.dart';

class ProcessStepData {
  final int step;
  final String title;
  final String description;
  final IconData icon;
  final bool isActive;

  const ProcessStepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    this.isActive = false,
  });
}

class ProcessSteps extends StatelessWidget {
  final String heading;
  final List<ProcessStepData> steps;

  const ProcessSteps({
    super.key,
    required this.heading,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
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
            heading,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          SizedBox(height: 16),
          ...steps.map((s) => _ProcessStepItem(data: s)).toList(),
        ],
      ),
    );
  }
}

class _ProcessStepItem extends StatelessWidget {
  final ProcessStepData data;

  const _ProcessStepItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.isActive ? Colors.deepPurple : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              data.icon,
              color: data.isActive ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.step}. ${data.title}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: data.isActive ? Colors.deepPurple.shade800 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  data.description,
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
}


