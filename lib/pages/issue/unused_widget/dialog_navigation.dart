import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/utils/activity_type_util.dart';
import 'package:provider/provider.dart';

class IssueDetailNavigation extends StatelessWidget {
  final void Function(ActivityType) onSelected;
  const IssueDetailNavigation({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    ActivityType currentChoice = context.watch<ActivityType>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
            label: const Text("All"),
            showCheckmark: false,
            selected: currentChoice == ActivityType.all,
            onSelected: (value) => onSelected(ActivityType.all)),
        const SizedBox(
          width: 20,
        ),
        ChoiceChip(
            label: const Text("Logs"),
            showCheckmark: false,
            selected: currentChoice == ActivityType.logs,
            onSelected: (value) => onSelected(ActivityType.logs)),
        const SizedBox(
          width: 20,
        ),
        ChoiceChip(
          label: const Text("Comments"),
          selected: currentChoice == ActivityType.comment,
          showCheckmark: false,
          onSelected: (value) => onSelected(ActivityType.comment),
        ),
      ],
    );
  }
}
