import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Simple info page with title, content, and return button
class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),

            // Return Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Return to Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// About Dosely Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'About Dosely',
      content: '''
Dosely is your personal medication safety assistant.

Scan any medication label or search by name to get instant AI-powered analysis, including drug interactions, side effects, and personalized safety guidance based on your health profile.

Built with accessibility at its core - featuring adjustable text sizes, colorblind-friendly modes, voice assistance, and support for any language.

Version 1.0.0
''',
    );
  }
}

/// Disclaimer & Data Sources Page
class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Disclaimer & Sources',
      content: '''
Data Sources:
Dosely uses AI-powered analysis (Google Gemini) combined with general medical knowledge to provide medication information and safety guidance.

Important Disclaimer:
This app is for informational purposes only and does NOT replace professional medical advice. Always consult your doctor, pharmacist, or healthcare provider before making any decisions about your medications.

AI Limitations:
While we strive for accuracy, AI-generated information may contain errors. Always verify important medical information with a qualified professional.
''',
    );
  }
}

/// Privacy Policy Page
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Privacy Policy',
      content: '''
Your Privacy Matters.

Data Storage:
All your health profile data, medications, and preferences are stored locally on your device. We do not upload or store your personal information on external servers.

AI Processing:
When you scan a medication or use AI features, the text is sent to secure AI services for analysis. Your personal health profile is included to provide personalized guidance but is not permanently stored by the AI provider.

No Tracking:
Dosely does not use analytics, advertising trackers, or sell your data.

Your Control:
You can clear all your data at any time using the "Clear Scan History" button in Settings.
''',
    );
  }
}
