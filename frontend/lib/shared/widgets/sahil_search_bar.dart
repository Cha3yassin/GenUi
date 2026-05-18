import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Search bar with animated placeholder text that cycles through examples.
class SahilSearchBar extends StatefulWidget {
  const SahilSearchBar({
    this.controller,
    this.hintText = 'Search procedures',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.placeholderExamples = const [],
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<String> placeholderExamples;

  @override
  State<SahilSearchBar> createState() => _SahilSearchBarState();
}

class _SahilSearchBarState extends State<SahilSearchBar>
    with SingleTickerProviderStateMixin {
  int _currentExample = 0;
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.value = 1.0;

    if (widget.placeholderExamples.isNotEmpty && widget.readOnly) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _cycleText());
    }
  }

  void _cycleText() {
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentExample =
            (_currentExample + 1) % widget.placeholderExamples.length;
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasExamples = widget.placeholderExamples.isNotEmpty && widget.readOnly;

    if (hasExamples) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppTheme.mutedInk.withOpacity(0.5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    widget.placeholderExamples[_currentExample],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTheme.mutedInk.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: AppTheme.mutedInk.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    return TextField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}
