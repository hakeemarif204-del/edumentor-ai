import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_store.dart';

class SecurityTab extends StatelessWidget {
  const SecurityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔐 Security & Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(16)),
              child: const Text(
                "Your child's learning record stays with this parent account.",
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Parent PIN', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Require a PIN to open Parent Zone'),
              value: store.pinEnabled,
              onChanged: store.setPinEnabled,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_reset, color: Color(0xFF6B4EFF)),
              title: const Text('Change Parent PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changePin(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt, color: Color(0xFF6B4EFF)),
              title: const Text('Reset PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _resetPin(context),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign out of parent account'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text('Lock Parents Zone', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changePin(BuildContext context) {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Parent PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: current, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, decoration: const InputDecoration(labelText: 'Current PIN')),
            TextField(controller: next, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, decoration: const InputDecoration(labelText: 'New PIN')),
            TextField(controller: confirm, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, decoration: const InputDecoration(labelText: 'Confirm New PIN')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final store = AppStore.instance;
              if (store.pinIsSet && current.text != store.pin) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current PIN is not right.')));
                return;
              }
              if (next.text.length != 4 || next.text != confirm.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the same 4-digit PIN twice.')));
                return;
              }
              if (AppStore.weakPin(next.text)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a PIN that is not 1234 or four matching digits.')));
                return;
              }
              store.setPin(next.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN saved.')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetPin(BuildContext context) {
    final next = TextEditingController();
    final confirm = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You are already inside Parent Zone, so you can choose a new PIN.'),
            TextField(controller: next, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, decoration: const InputDecoration(labelText: 'New PIN')),
            TextField(controller: confirm, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, decoration: const InputDecoration(labelText: 'Confirm PIN')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (next.text.length != 4 || next.text != confirm.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the same 4-digit PIN twice.')));
                return;
              }
              if (AppStore.weakPin(next.text)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a PIN that is not 1234 or four matching digits.')));
                return;
              }
              AppStore.instance.setPin(next.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
