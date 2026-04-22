import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({required this.value, required this.data, super.key});

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // Skip showing debounce cancellation errors
        if (error.toString().contains('Search cancelled')) {
          return const SizedBox.shrink();
        }
        
        // Clean up error message
        final message = error.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 56, color: Colors.orangeAccent),
                const SizedBox(height: 16),
                Text(
                  message.isNotEmpty ? message : 'Une erreur est survenue. L\'IA est peut-être surchargée.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
