import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'read_aloud_button.dart';

/// Dosely app header with logo and accessibility controls
class DoselyHeader extends StatelessWidget {
  const DoselyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title
          Row(
            children: [
              // App Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.surface.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background decoration
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // D letter
                    const Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    // Pill dot
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dosely',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(letterSpacing: -0.5),
              ),
            ],
          ),

          // Right side controls
          Row(
            children: [
              const ReadAloudButton(),
              const SizedBox(width: 8),
              // Language toggle removed as per request
              // Container(...)
            ],
          ),
        ],
      ),
    );
  }
}
