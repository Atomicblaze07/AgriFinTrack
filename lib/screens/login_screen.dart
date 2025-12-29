import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isFirstTime;
  const LoginScreen({super.key, required this.isFirstTime});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleSubmit() async {
    final pin = _controller.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'Enter 4-digit PIN');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = AuthService();
    if (widget.isFirstTime) {
      await auth.savePin(pin);
      _goToDashboard();
    } else {
      final ok = await auth.validatePin(pin);
      if (ok) {
        _goToDashboard();
      } else {
        setState(() => _error = 'Wrong PIN');
      }
    }

    setState(() => _isLoading = false);
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFirstTime ? 'Create PIN' : 'Enter PIN';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'AgriFinTrack',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '4-digit PIN',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.isFirstTime ? 'Save PIN' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
