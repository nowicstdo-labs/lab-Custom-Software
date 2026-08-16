import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _smsUpdatesEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsSectionHeader(title: 'PREFERENCES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeThumbColor: const Color(0xFF00796B),
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Receive appointment and report alerts', style: TextStyle(fontSize: 12)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: _smsUpdatesEnabled,
                  onChanged: (v) => setState(() => _smsUpdatesEnabled = v),
                  activeThumbColor: const Color(0xFF00796B),
                  title: const Text('SMS Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Receive booking details via SMS', style: TextStyle(fontSize: 12)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: _biometricEnabled,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                  activeThumbColor: const Color(0xFF00796B),
                  title: const Text('Biometric Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Use fingerprint/face ID to unlock', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SettingsSectionHeader(title: 'LANGUAGE & REGION'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: const Text('App Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: ['English', 'Hindi', 'Bengali', 'Urdu']
                      .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLanguage = v!),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _SettingsSectionHeader(title: 'ACCOUNT & PRIVACY'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy displayed')),
                    );
                  },
                  title: const Text('Privacy Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms of Service displayed')),
                    );
                  },
                  title: const Text('Terms of Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00796B),
        letterSpacing: 0.8,
      ),
    );
  }
}
