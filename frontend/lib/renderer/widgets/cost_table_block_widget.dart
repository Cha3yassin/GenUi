import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/fee_model.dart';

/// Cost table with a total row at the bottom.
class CostTableBlockWidget extends StatelessWidget {
  const CostTableBlockWidget({required this.data, this.locale = 'fr', super.key});

  final Map<String, dynamic> data;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final fees = (data['fees'] as List<dynamic>? ?? [])
        .map((item) => FeeModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // Compute total by parsing numeric values from fee amounts
    double total = 0;
    String currency = 'TND';
    for (final fee in fees) {
      final numMatch = RegExp(r'[\d.,]+').firstMatch(fee.amount);
      if (numMatch != null) {
        total += double.tryParse(numMatch.group(0)!.replaceAll(',', '.')) ?? 0;
      }
      // Extract currency from the amount string
      final currMatch = RegExp(r'[A-Za-z]+').firstMatch(fee.amount);
      if (currMatch != null) {
        currency = currMatch.group(0)!;
      }
    }

    final totalLabel = locale == 'ar'
        ? 'المجموع'
        : locale == 'en'
            ? 'Total'
            : 'Total';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (final fee in fees) _FeeRow(fee: fee),
            if (fees.length > 1) ...[
              const SizedBox(height: 6),
              Divider(color: AppTheme.borderLight, height: 1),
              const SizedBox(height: 12),
              // Total row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      totalLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)} $currency',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.terracotta,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.fee});

  final FeeModel fee;

  @override
  Widget build(BuildContext context) {
    final isFree = fee.amount.trim() == '0 TND' || fee.amount.trim() == '0.0 TND' || fee.amount.trim() == '0,0 TND' || fee.amount.trim() == '0';
    final amountText = isFree ? 'Gratuit' : fee.amount;
    final amountColor = isFree ? AppTheme.olive : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fee.label, style: Theme.of(context).textTheme.titleSmall),
                if (fee.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    fee.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amountText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: amountColor,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
