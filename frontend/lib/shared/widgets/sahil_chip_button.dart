import 'package:flutter/material.dart';

class SahilChipButton extends StatelessWidget {
  const SahilChipButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon == null ? null : Icon(icon, size: 17),
      label: Text(label),
      onPressed: onPressed,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    );
  }
}
