import 'package:flutter/material.dart';
import '../models/router_config.dart';

class RouterFormScreen extends StatefulWidget {
  const RouterFormScreen({super.key});

  @override
  State<RouterFormScreen> createState() => _RouterFormScreenState();
}

class _RouterFormScreenState extends State<RouterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '443');
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _https = true;

  @override
  void dispose() {
    _name.dispose();
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      RouterConfig(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        host: _host.text.trim(),
        port: int.tryParse(_port.text.trim()) ?? (_https ? 443 : 80),
        useHttps: _https,
        username: _username.text.trim(),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add MikroTik')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Router name',
                hintText: 'Student Housing',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _host,
              decoration: const InputDecoration(
                labelText: 'IP / Host',
                hintText: '192.168.88.1',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _port,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'REST port'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _https,
              title: const Text('Use HTTPS'),
              subtitle: const Text('Recommended for production'),
              onChanged: (v) => setState(() => _https = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Router username'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Router password'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save router'),
            ),
          ],
        ),
      ),
    );
  }
}
