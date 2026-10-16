import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import 'parents_zone_screen.dart';

/// Secure 4-digit PIN entry gating access to the Parents Zone.
/// TODO: Replace the hardcoded _correctPin with a value stored securely
/// (e.g. Firestore under the parent's account, or flutter_secure_storage)
/// once Parent Settings -> Security -> Change PIN is built.
class ParentPinScreen extends StatefulWidget {
  const ParentPinScreen({super.key});

  @override
  State<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends State<ParentPinScreen> {
  String _enteredPin = '';
  bool _showError = false;
  bool _confirming = false;
  String _firstPin = '';
  String? _message;

  bool get _creating => !AppStore.instance.pinIsSet;
  bool get _locked => AppStore.instance.pinIsLocked;

  @override
  void initState() {
    super.initState();
    AppStore.instance.loadPinGuard();
    if (_locked) {
      _tickLock();
    }
  }

  void _tickLock() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      AppStore.instance.loadPinGuard();
      setState(() {});
      if (_locked) _tickLock();
    });
  }

  void _onDigitTap(String digit) {
    if (_locked || _enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _showError = false;
    });

    if (_enteredPin.length == 4) {
      _checkPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _showError = false;
    });
  }

  Future<void> _checkPin() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    if (_creating) {
      if (!_confirming) {
        if (AppStore.weakPin(_enteredPin)) {
          setState(() {
            _showError = true;
            _message = 'Pick a PIN that is not 1234 or the same digit four times.';
            _enteredPin = '';
          });
          return;
        }
        setState(() {
          _firstPin = _enteredPin;
          _enteredPin = '';
          _confirming = true;
          _message = null;
        });
        return;
      }
      if (_enteredPin == _firstPin) {
        AppStore.instance.setPin(_enteredPin);
        AppStore.instance.clearPinFailures();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ParentsZoneScreen()));
      } else {
        setState(() {
          _showError = true;
          _enteredPin = '';
          _confirming = false;
          _firstPin = '';
        });
      }
      return;
    }
    if (_enteredPin == AppStore.instance.pin) {
      AppStore.instance.clearPinFailures();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ParentsZoneScreen()));
    } else {
      AppStore.instance.noteWrongPin();
      setState(() {
        _showError = true;
        _enteredPin = '';
        _message = AppStore.instance.pinIsLocked
            ? 'Too many tries. The PIN pad will open again in a moment.'
            : 'That PIN is not right.';
      });
      if (AppStore.instance.pinIsLocked) _tickLock();
    }
  }

  Future<void> _showForgotPinDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Forgot PIN?'),
          content: const Text('Sign in with the parent email first. Then you can choose a new PIN.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    final password = TextEditingController();
    var error = '';
    var busy = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Confirm it is you'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the password for ${user.email} before choosing a new PIN.'),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Parent password'),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      setDialog(() => busy = true);
                      try {
                        final credential = EmailAuthProvider.credential(email: user.email!, password: password.text);
                        await user.reauthenticateWithCredential(credential);
                        if (!context.mounted) return;
                        AppStore.instance.setPin('');
                        AppStore.instance.clearPinFailures();
                        Navigator.pop(context);
                        setState(() {
                          _confirming = false;
                          _firstPin = '';
                          _enteredPin = '';
                          _showError = false;
                          _message = null;
                        });
                      } on FirebaseAuthException {
                        setDialog(() {
                          busy = false;
                          error = 'That password is not right.';
                        });
                      }
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3B2A5A)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🔐', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              _creating ? 'Choose a Parent PIN' : 'Parent Access',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _locked
                  ? 'The PIN pad is resting. Try again in ${AppStore.instance.pinLockedUntil!.difference(DateTime.now()).inSeconds + 1} seconds.'
                  : _creating
                      ? (_confirming ? 'Enter the same PIN again' : 'Pick 4 digits you will remember. Skip 1234.')
                      : 'Enter your 4-digit PIN to continue',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // PIN circles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? const Color(0xFF6B4EFF) : Colors.white,
                    border: Border.all(
                      color: _showError ? Colors.red : const Color(0xFF6B4EFF),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            if (_showError) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _message ?? (_creating ? 'Those PINs did not match. Start again.' : 'Incorrect PIN. Try again!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Number keypad
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                      _KeypadButton(label: d, onTap: () => _onDigitTap(d)),
                    const SizedBox.shrink(), // empty bottom-left cell
                    _KeypadButton(label: '0', onTap: () => _onDigitTap('0')),
                    _KeypadButton(
                      icon: Icons.backspace_outlined,
                      onTap: _onBackspace,
                    ),
                  ],
                ),
              ),
            ),

            TextButton(
              onPressed: _showForgotPinDialog,
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: icon != null
              ? Icon(icon, color: const Color(0xFF3B2A5A))
              : Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B2A5A),
                  ),
                ),
        ),
      ),
    );
  }
}