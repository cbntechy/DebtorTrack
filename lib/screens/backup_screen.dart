import 'package:debtortrack/core/services/backup_service.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();

  Map<String, dynamic>? _cloudBackup;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCloudBackup();
  }

  Future<void> _loadCloudBackup() async {
    try {
      final backup = await _backupService.getBackup();

      if (!mounted) return;

      setState(() {
        _cloudBackup = backup;
      });
    } catch (_) {
      if (mounted) {
        _showMessage('Could not load cloud backup.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _lastBackupLabel() {
    final value = _cloudBackup?['updatedAt'];

    if (value is! String) {
      return 'No cloud backup yet';
    }

    final date = DateTime.tryParse(value)?.toLocal();

    if (date == null) {
      return 'Backup date unavailable';
    }

    return 'Last backup: ${date.day}/${date.month}/${date.year} '
        'at ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _backupNow() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _backupService.backupNow();
      await _loadCloudBackup();

      if (mounted) {
        _showMessage('Backup completed successfully.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Backup failed. Check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _restoreBackup() async {
    if (_cloudBackup == null) {
      _showMessage('No cloud backup is available to restore.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restore cloud backup?'),
          content: const Text(
            'This will replace the debtors, templates, and currency currently stored on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _backupService.restoreBackup(_cloudBackup!);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Restore failed. Your local data was not changed.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        title: const Text('Cloud backup'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Signed in as',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_outlined, size: 34),
                        const SizedBox(height: 12),
                        Text(
                          _lastBackupLabel(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your debtor list, templates, and currency preference are saved privately to your account.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _isProcessing ? null : _backupNow,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _isProcessing ? 'Please wait...' : 'Back up now',
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _restoreBackup,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Restore backup'),
                ),
              ],
            ),
    );
  }
}