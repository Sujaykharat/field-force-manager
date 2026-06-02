import 'package:flutter/material.dart';
import '../../domain/task_model.dart';

class FilterChipGroup extends StatelessWidget {
  final TaskStatus? selectedStatus;
  final Function(TaskStatus?) onStatusSelected;

  const FilterChipGroup({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (selected) {
              if (selected) onStatusSelected(null);
            },
          ),
          const SizedBox(width: 8),
          ...TaskStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(status.displayName),
                selected: selectedStatus == status,
                onSelected: (selected) {
                  if (selected) onStatusSelected(status);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
