import 'package:flutter/material.dart';
import 'package:wego_marriage/screen/voice_call_screen.dart';
import 'package:wego_marriage/screen/video_call_screen.dart';

enum CallType { voice, video }
enum CallStatus { incoming, outgoing, missed }

class CallRecord {
  final String id;
  final String username;
  final String avatarUrl;
  final CallType callType;
  final CallStatus callStatus;
  final DateTime timestamp;
  final Duration? duration;

  CallRecord({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.callType,
    required this.callStatus,
    required this.timestamp,
    this.duration,
  });
}

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {

  // Sample call history data
  late final List<CallRecord> _callHistory;

  @override
  void initState() {
    super.initState();
    _callHistory = [
      CallRecord(
        id: '1',
        username: 'Emelie',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        callType: CallType.voice,
        callStatus: CallStatus.missed,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      CallRecord(
        id: '2',
        username: 'Abigail',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        callType: CallType.video,
        callStatus: CallStatus.outgoing,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 12, seconds: 34),
      ),
      CallRecord(
        id: '3',
        username: 'Elizabeth',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        callType: CallType.voice,
        callStatus: CallStatus.incoming,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 5, seconds: 18),
      ),
      CallRecord(
        id: '4',
        username: 'Penelope',
        avatarUrl: 'https://i.pravatar.cc/150?img=7',
        callType: CallType.video,
        callStatus: CallStatus.missed,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getCallIcon(CallType type, CallStatus status) {
    switch (status) {
      case CallStatus.incoming:
        return type == CallType.voice ? Icons.call_received : Icons.videocam;
      case CallStatus.outgoing:
        return type == CallType.voice ? Icons.call_made : Icons.videocam;
      case CallStatus.missed:
        return type == CallType.voice ? Icons.phone_missed : Icons.videocam_off;
    }
  }

  Color _getCallColor(CallStatus status) {
    switch (status) {
      case CallStatus.incoming:
        return Colors.green;
      case CallStatus.outgoing:
        return Colors.blue;
      case CallStatus.missed:
        return Colors.red;
    }
  }

  void _makeCall(BuildContext context, CallRecord record) {
    if (record.callType == CallType.voice) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            username: record.username,
            avatarUrl: record.avatarUrl,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            username: record.username,
            avatarUrl: record.avatarUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        title: const Text(
          'Call History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _callHistory.length,
        itemBuilder: (context, index) {
          final record = _callHistory[index];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(record.avatarUrl),
                  backgroundColor: Colors.grey[300],
                  child: record.avatarUrl.startsWith('https')
                      ? null
                      : const Icon(Icons.person, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getCallColor(record.callStatus),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _getCallIcon(record.callType, record.callStatus),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              record.username,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCallIcon(record.callType, record.callStatus),
                      size: 16,
                      color: _getCallColor(record.callStatus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.callStatus == CallStatus.missed
                          ? 'Missed ${record.callType == CallType.voice ? 'voice' : 'video'} call'
                          : record.callStatus == CallStatus.incoming
                              ? 'Incoming ${record.callType == CallType.voice ? 'voice' : 'video'} call'
                              : 'Outgoing ${record.callType == CallType.voice ? 'voice' : 'video'} call',
                      style: TextStyle(
                        color: record.callStatus == CallStatus.missed
                            ? Colors.red
                            : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (record.duration != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Duration: ${_formatDuration(record.duration!)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(record.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (record.callStatus != CallStatus.missed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (record.callType == CallType.voice)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF075E54),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.call, color: Colors.white, size: 20),
                            onPressed: () => _makeCall(context, record),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF075E54),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.videocam, color: Colors.white, size: 20),
                            onPressed: () => _makeCall(context, record),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            onTap: () => _makeCall(context, record),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "voice_call",
            backgroundColor: const Color(0xFF075E54),
            onPressed: () {
              // Show contact list for voice call
            },
            child: const Icon(Icons.call, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "video_call",
            backgroundColor: const Color(0xFF075E54),
            onPressed: () {
              // Show contact list for video call
            },
            child: const Icon(Icons.videocam, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
