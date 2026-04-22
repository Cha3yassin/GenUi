import 'package:flutter/material.dart';

import '../models/office_model.dart';
import 'status_badge.dart';

class OfficeCard extends StatelessWidget {
  const OfficeCard({required this.office, super.key});

  final OfficeModel office;

  @override
  Widget build(BuildContext context) {
    final statusColor = office.isOpen
        ? const Color(0xFF3F7D4F)
        : const Color(0xFF9A4B3F);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        office.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        office.type,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: office.isOpen ? 'Open' : 'Closed',
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _OfficeMeta(icon: Icons.near_me_rounded, label: office.distance),
            const SizedBox(height: 8),
            _OfficeMeta(
              icon: Icons.schedule_rounded,
              label: office.workingHours,
            ),
            const SizedBox(height: 8),
            _OfficeMeta(icon: Icons.place_rounded, label: office.address),
          ],
        ),
      ),
    );
  }
}

class _OfficeMeta extends StatelessWidget {
  const _OfficeMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
