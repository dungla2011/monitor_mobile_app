import 'package:flutter/material.dart';
import '../services/system_tray_service.dart';

/// Dialog for system tray options
class TrayOptionsDialog extends StatefulWidget {
  const TrayOptionsDialog({Key? key}) : super(key: key);

  @override
  State<TrayOptionsDialog> createState() => _TrayOptionsDialogState();
}

class _TrayOptionsDialogState extends State<TrayOptionsDialog> {
  bool _isAutoStartEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SystemTrayService.isAutoStartEnabled();
    if (mounted) {
      setState(() {
        _isAutoStartEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoStart(bool? value) async {
    if (value == null) return;

    setState(() {
      _isLoading = true;
    });

    if (value) {
      await SystemTrayService.enableAutoStart();
    } else {
      await SystemTrayService.disableAutoStart();
    }

    if (mounted) {
      setState(() {
        _isAutoStartEnabled = value;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else
            CheckboxListTile(
              title: const Text('Start up with Windows'),
              subtitle: const Text('Launch automatically when Windows starts'),
              value: _isAutoStartEnabled,
              onChanged: _toggleAutoStart,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
