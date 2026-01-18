import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/profile.dart';
import '../../../core/providers/profile_provider.dart';
import '../../widgets/edit_profile_dialog.dart';
import '../../widgets/medical_profile_dialog.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/read_aloud_button.dart';

/// Profile screen - displays user information and medical profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    // Formatting date
    final memberSinceYear = profile.memberSince.year;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.border, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.navProfile,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const ReadAloudButton(),
                  ],
                ),
              ),

              // Profile Summary Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppTheme.surface,
                                width: 4,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        profile.isEmpty ? 'Your Name' : profile.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color:
                              profile.isEmpty
                                  ? AppTheme.textSub
                                  : AppTheme.textMain,
                          fontStyle:
                              profile.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (profile.pronouns.isNotEmpty)
                            _buildTag(context, profile.pronouns, false),
                          if (profile.pronouns.isNotEmpty)
                            const SizedBox(width: 8),
                          _buildTag(
                            context,
                            'Member since $memberSinceYear',
                            true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Vitals Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildVitalCard(
                        context,
                        Icons.cake,
                        l10n.profileAge,
                        profile.age > 0 ? profile.age.toString() : 'N/A',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVitalCard(
                        context,
                        Icons.female,
                        l10n.profileSex,
                        profile.sex.isNotEmpty ? profile.sex : '-',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildVitalCard(
                  context,
                  Icons.pregnant_woman,
                  l10n.profilePregnancy,
                  profile.isPregnant ? 'Pregnant' : l10n.profileNotPregnant,
                  showCheck:
                      !profile
                          .isPregnant, // Show check if simple "Not Pregnant" ? Or maybe show check if status is confirmed.
                  // Original: showCheck: true for "Not Pregnant". Let's keep it consistent with "Safe" feeling.
                ),
              ),

              // Medical Profile Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.profileMedicalProfile,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),

              // Allergies Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMedicalCard(
                  context,
                  Icons.warning,
                  l10n.profileAllergies,
                  profile.allergies,
                  Colors.red,
                  l10n.profileEdit,
                  onEditInteract: () async {
                    final result = await showDialog<UserProfile>(
                      context: context,
                      builder:
                          (context) =>
                              MedicalProfileDialog(initialProfile: profile),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileProvider>().updateProfile(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Allergies updated')),
                      );
                    }
                  },
                  emptyText: l10n.profileNoAllergies,
                ),
              ),
              const SizedBox(height: 12),

              // Conditions Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMedicalCard(
                  context,
                  Icons.monitor_heart,
                  l10n.profileConditions,
                  profile.conditions,
                  AppTheme.primary,
                  l10n.profileEdit,
                  onEditInteract: () async {
                    final result = await showDialog<UserProfile>(
                      context: context,
                      builder:
                          (context) =>
                              MedicalProfileDialog(initialProfile: profile),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileProvider>().updateProfile(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conditions updated')),
                      );
                    }
                  },
                  emptyText: l10n.profileNoConditions,
                ),
              ),

              // Edit Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<UserProfile>(
                      context: context,
                      builder:
                          (context) =>
                              EditProfileDialog(initialProfile: profile),
                    );
                    if (result != null && context.mounted) {
                      context.read<ProfileProvider>().updateProfile(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated')),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit_document),
                  label: Text(l10n.profileEditFull),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryLight : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isPrimary ? AppTheme.primary : AppTheme.textSub,
        ),
      ),
    );
  }

  Widget _buildVitalCard(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool showCheck = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppTheme.textLight),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          if (showCheck)
            const Icon(
              Icons.check_circle,
              color: AppTheme.statusSafe,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard(
    BuildContext context,
    IconData icon,
    String title,
    List<String> items,
    Color color,
    String editText, {
    VoidCallback? onEditInteract,
    String emptyText = 'None',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelLarge),
                    TextButton(
                      onPressed: onEditInteract ?? () {},
                      child: Text(editText),
                    ),
                  ],
                ),
                if (items.isEmpty)
                  Text(
                    emptyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSub,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        items
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    color: Color.lerp(color, Colors.black, 0.4),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
