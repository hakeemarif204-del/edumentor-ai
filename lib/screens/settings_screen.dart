import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import 'children_profiles_tab.dart';
import 'security_tab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final email = FirebaseAuth.instance.currentUser?.email ?? store.parentEmail;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader('Account'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Parent name',
              subtitle: store.parentName.isEmpty ? 'Not set' : store.parentName,
              onTap: () => _editText(context, 'Parent name', store.parentName, store.setParentName),
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: email.isEmpty ? 'Not signed in' : email,
              onTap: () => _editEmail(context),
            ),
            _SettingsTile(
              icon: Icons.emoji_emotions_outlined,
              title: 'Profile picture',
              subtitle: store.parentEmoji,
              onTap: () => _pickEmoji(context),
            ),
            const _SectionHeader('Child Settings'),
            _SettingsTile(
              icon: Icons.child_care,
              title: 'Manage children',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: SafeArea(child: ChildrenProfilesTab()),
                    ),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.tune,
              title: 'Learning focus',
              subtitle: store.activeChild.focusSubject,
              onTap: () => _pickFocus(context),
            ),
            const _SectionHeader('Notifications'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Achievement notifications'),
              value: store.achievementNotifs,
              onChanged: store.setAchievementNotifs,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Progress reports'),
              value: store.progressReports,
              onChanged: store.setProgressReports,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AI recommendations'),
              value: store.aiRecommendations,
              onChanged: store.setAiRecommendations,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily reminders'),
              value: store.dailyReminder,
              onChanged: store.setDailyReminder,
            ),
            const _SectionHeader('Security'),
            _SettingsTile(
              icon: Icons.lock_reset,
              title: 'Change PIN',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: SafeArea(child: SecurityTab()))));
              },
            ),
            const _SectionHeader('App'),
            _SettingsTile(icon: Icons.language, title: 'Language', subtitle: store.language, onTap: () => _pickLanguage(context)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              value: store.soundEnabled,
              onChanged: store.setSound,
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _info(context, 'Help', 'Open any home tile to play. Parent Zone shows the real record of what your child did. The microphone needs permission the first time you talk to Edu Mentor.'),
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About Edu Mentor AI',
              subtitle: store.syncNote,
              onTap: () => _info(context, 'About', 'Edu Mentor AI keeps learning on this phone and copies it to the parent account when you are signed in.'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editText(BuildContext context, String label, String current, void Function(String) save) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (value != null) save(value);
  }

  Future<void> _editEmail(BuildContext context) async {
    final controller = TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? AppStore.instance.parentEmail);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email'),
        content: TextField(controller: controller, keyboardType: TextInputType.emailAddress),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (value == null || !context.mounted) return;
    final message = await AppStore.instance.requestEmailChange(value);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _pickEmoji(BuildContext context) {
    const emojis = ['🛡️', '👩', '👨', '🧑', '💜', '🌟'];
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          for (final emoji in emojis)
            IconButton(
              onPressed: () {
                AppStore.instance.setParentEmoji(emoji);
                Navigator.pop(context);
              },
              icon: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
        ],
      ),
    );
  }

  void _pickFocus(BuildContext context) {
    const focuses = ['Alphabets', 'Numbers', 'Shapes', 'Colours', 'Rhymes', 'Stories'];
    final child = AppStore.instance.activeChild;
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final focus in focuses)
            ListTile(
              title: Text(focus),
              trailing: child.focusSubject == focus ? const Icon(Icons.check) : null,
              onTap: () {
                child.focusSubject = focus;
                AppStore.instance.updateChild(child);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    const languages = ['English', 'French', 'Arabic'];
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final language in languages)
            ListTile(
              title: Text(language),
              subtitle: language == 'English' ? null : const Text('The voice follows this choice. Lessons stay in English.'),
              onTap: () {
                AppStore.instance.setLanguage(language);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _info(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF6B4EFF)),
      title: Text(title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
