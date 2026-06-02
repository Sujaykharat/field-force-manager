import 'package:flutter/material.dart';
import '../../domain/activity_model.dart';
import 'package:intl/intl.dart';

class ActivityTile extends StatelessWidget {
  final ActivityLog log;
  final bool isLast;

  const ActivityTile({super.key, required this.log, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getIconColor(log.type),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.message,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(log.timestamp),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(ActivityType type) {
    switch (type) {
      case ActivityType.taskCreated:
        return Colors.purple;
      case ActivityType.taskAssigned:
        return Colors.blue;
      case ActivityType.visitStarted:
        return Colors.orange;
      case ActivityType.visitCompleted:
        return Colors.green;
      case ActivityType.noteAdded:
        return Colors.blueGrey;
      case ActivityType.statusChanged:
        return Colors.teal;
    }
  }
}
