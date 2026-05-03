import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// Widget for managing call history backup and restore
/// Similar to ChatBackupWidget but specifically for call logs
class CallBackupWidget extends StatefulWidget {
  const CallBackupWidget({super.key});

  @override
  State<CallBackupWidget> createState() => _CallBackupWidgetState();
}

class _CallBackupWidgetState extends State<CallBackupWidget> {
  final LocalStorageService _storage = LocalStorageService();
  bool _hasBackup = false;
  bool _isLoading = false;
  int _totalCalls = 0;

  @override
  void initState() {
    super.initState();
    _checkBackup();
    _countCalls();
  }

  Future<void> _checkBackup() async {
    final hasBackup = await _storage.hasBackupFile();
    setState(() => _hasBackup = hasBackup);
  }

  void _countCalls() {
    // Count call logs from all chat histories
    final chattedUsers = _storage.getChattedUsers();
    int callCount = 0;

    for (final userId in chattedUsers) {
      final messages = _storage.getChatMessages(userId);
      for (final msg in messages) {
        if (msg['type'] == 8) { // MsgType.callLog index
          callCount++;
        }
      }
    }

    setState(() => _totalCalls = callCount);
  }

  Future<void> _exportCalls() async {
    setState(() => _isLoading = true);
    try {
      // Export all data (includes calls as they're part of chat history)
      final path = await _storage.exportAllChatsToFile();
      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call history backed up to: $path'),
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
              content: Text('Failed to backup call history'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCalls() async {
    setState(() => _isLoading = true);
    try {
      final success = await _storage.importChatsFromFile();
      if (success) {
        _countCalls();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Call history restored successfully!'),
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

  Future<void> _clearCallHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Clear Call History?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all call logs from your chat history. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        // Get all users and their messages
        final chattedUsers = _storage.getChattedUsers();

        for (final userId in chattedUsers) {
          final messages = _storage.getChatMessages(userId);
          // Filter out call logs
          final filteredMessages = messages.where((msg) => msg['type'] != 8).toList();
          // Save back without call logs
          await _storage.saveChatMessages(userId, filteredMessages);
        }

        _countCalls();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Call history cleared'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.call,
                    color: Color(0xFF6B4EFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call History Backup',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_totalCalls calls recorded',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasBackup)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Column(
                children: [
                  // Export Calls
                  InkWell(
                    onTap: _exportCalls,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.backup,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup Call History',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Save to Downloads folder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Import Calls
                  InkWell(
                    onTap: _hasBackup ? _importCalls : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restore,
                            color: _hasBackup
                                ? (isDark ? Colors.white.withOpacity(0.7) : Colors.black54)
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Restore Call History',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _hasBackup
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _hasBackup
                                      ? 'Import from backup file'
                                      : 'No backup file available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _hasBackup
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_hasBackup)
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Clear Call History
                  InkWell(
                    onTap: _totalCalls > 0 ? _clearCallHistory : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: _totalCalls > 0 ? Colors.red.shade300 : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clear Call History',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _totalCalls > 0
                                        ? Colors.red.shade300
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Remove all call logs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _totalCalls > 0
                                        ? Colors.red.shade200.withValues(alpha: 0.7)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
