import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import 'parent_pin_screen.dart';
import 'parents_zone_screen.dart';

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _notice;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No parent account uses that email. You can create one below.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'That email and password do not match.';
      case 'email-already-in-use':
        return 'That email already has a parent account. Sign in instead.';
      case 'weak-password':
        return 'Use at least 6 characters, and mix letters with a number.';
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'network-request-failed':
        return 'No internet connection. Check the network and try again.';
      case 'too-many-requests':
        return 'Too many tries. Wait a minute, then try again.';
      case 'user-disabled':
        return 'This parent account has been turned off.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  bool _validEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _notice = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        try {
          await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        } catch (_) {}
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }
      AppStore.instance.rememberParent(
        name: _isSignUp ? _nameController.text : null,
        email: email,
      );
      if (!mounted) return;
      final next = AppStore.instance.pinEnabled ? const ParentPinScreen() : const ParentsZoneScreen();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
    } on FirebaseAuthException catch (error) {
      setState(() => _errorMessage = _friendlyError(error));
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (!_validEmail(email)) {
      setState(() {
        _errorMessage = 'Enter the parent email first, then tap Forgot password.';
        _notice = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _notice = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() => _notice = 'A reset link is on its way to $email. Open it, choose a new password, then sign in here.');
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF3B2A5A)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text('🛡️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                _isSignUp ? 'Create a parent account' : 'Parent sign in',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF3B2A5A)),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'This account keeps your child’s learning. You will choose a 4-digit PIN next.'
                    : 'Sign in with the parent email. The PIN comes after this.',
                style: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF7D6E90)),
              ),
              const SizedBox(height: 24),
              if (_isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _field('Your name'),
                  validator: (value) {
                    if (!_isSignUp) return null;
                    if (value == null || value.trim().length < 2) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: _field('Email'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!_validEmail(email)) return 'Enter a real email, like name@email.com';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isSignUp) _submit();
                },
                decoration: _field('Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your password';
                  if (value.length < 6) return 'Use at least 6 characters';
                  if (_isSignUp && !RegExp(r'[A-Za-z]').hasMatch(value)) return 'Include at least one letter';
                  if (_isSignUp && !RegExp(r'\d').hasMatch(value)) return 'Include at least one number';
                  return null;
                },
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _field('Confirm password'),
                  validator: (value) {
                    if (!_isSignUp) return null;
                    if (value != _passwordController.text) return 'Those passwords do not match';
                    return null;
                  },
                ),
              ],
              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _sendPasswordReset,
                    child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF6B4EFF))),
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, height: 1.3)),
              ],
              if (_notice != null) ...[
                const SizedBox(height: 8),
                Text(_notice!, style: const TextStyle(color: Color(0xFF2E7D32), height: 1.3)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isSignUp ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                            _notice = null;
                          });
                        },
                  child: Text(
                    _isSignUp ? 'Already have an account? Sign in' : 'New here? Create a parent account',
                    style: const TextStyle(color: Color(0xFF3B2A5A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
