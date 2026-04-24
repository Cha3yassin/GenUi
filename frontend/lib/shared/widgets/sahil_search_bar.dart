import 'package:flutter/material.dart';

enum SahilSearchBarVariant { soft, professional }

class SahilSearchBar extends StatelessWidget {
  const SahilSearchBar({
    this.controller,
    this.hintText = 'Search procedures',
    this.contextLabel,
    this.accentColor,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.variant = SahilSearchBarVariant.soft,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final String? contextLabel;
  final Color? accentColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final SahilSearchBarVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;
    final isProfessional = variant == SahilSearchBarVariant.professional;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contextLabel != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isProfessional ? 0.06 : 0.08),
              borderRadius: BorderRadius.circular(isProfessional ? 12 : 99),
              border: isProfessional
                  ? Border.all(color: color.withValues(alpha: 0.16))
                  : null,
            ),
            child: Text(
              contextLabel!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                  ),
            ),
          ),
        ],
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.search_rounded, color: color),
            suffixIcon: Icon(
              isProfessional ? Icons.tune_rounded : Icons.tune_rounded,
              color: isProfessional ? color.withValues(alpha: 0.82) : null,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            fillColor: isProfessional ? Colors.white : null,
            enabledBorder: isProfessional
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: color.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                  )
                : null,
            focusedBorder: isProfessional
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color, width: 1.5),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
