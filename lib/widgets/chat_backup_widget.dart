import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// Widget for backing up and restoring chat history
/// Add this to your Settings screen for manual backup/restore
class ChatBackupWidget extends StatefulWidget {
  const ChatBackupWidget({super.key});

  @override
  State<ChatBackupWidget> createState() => _ChatBackupWidgetState();
}

class _ChatBackupWidgetState extends State<ChatBackupWidget> {
  final LocalStorageService _storage = LocalStorageService();
  bool _hasBackup = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBackup();
  }

  Future<void> _checkBackup() async {
    final hasBackup = await _storage.hasBackupFile();
    setState(() => _hasBackup = hasBackup);
  }

  Future<void> _exportChats() async {
    setState(() => _isLoading = true);
    try {
      final path = await _storage.exportAllChatsToFile();
      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chats backed up to: $path'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _checkBackup();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to backup chats'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importChats() async {
    setState(() => _isLoading = true);
    try {
      final success = await _storage.importChatsFromFile();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chats restored successfully! Restart app to see changes.'),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No backup file found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAllChats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Chats?'),
        content: const Text('This will permanently delete all chat history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _storage.deleteAllChatHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All chats deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
        await _checkBackup();
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backup,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  'Chat Backup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_hasBackup)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Backup Available',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Backup your chats to keep them safe even if you uninstall the app.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.upload, color: Color(0xFF6B4EFF)),
                    title: const Text('Export Chats'),
                    subtitle: const Text('Save backup to Downloads folder'),
                    onTap: _exportChats,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download, color: Color(0xFF2EC4B6)),
                    title: const Text('Import Chats'),
                    subtitle: Text(_hasBackup
                        ? 'Restore from backup file'
                        : 'No backup file found'),
                    onTap: _hasBackup ? _importChats : null,
                    enabled: _hasBackup,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete All Chats', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Permanently delete all chat history'),
                    onTap: _deleteAllChats,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple function to check and restore chats on app startup
/// Call this in your main.dart or splash screen
Future<void> checkAndRestoreChatsOnStartup() async {
  final storage = LocalStorageService();

  // Check if we have any existing chats
  final chattedUsers = storage.getChattedUsers();

  // If no chats exist but backup file exists, restore it
  if (chattedUsers.isEmpty) {
    final hasBackup = await storage.hasBackupFile();
    if (hasBackup) {
      // Ask user if they want to restore (you can show a dialog here)
      // For now, auto-restore
      await storage.importChatsFromFile();
    }
  }
}
