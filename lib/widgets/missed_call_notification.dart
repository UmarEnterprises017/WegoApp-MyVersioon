import 'package:flutter/material.dart';
import 'package:wego_marriage/screen/voice_call_screen.dart';
import 'package:wego_marriage/screen/video_call_screen.dart';

class MissedCallNotification extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final bool isVideoCall;
  final VoidCallback? onCallback;
  final VoidCallback? onDismiss;

  const MissedCallNotification({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.isVideoCall = false,
    this.onCallback,
    this.onDismiss,
  });

  void _makeCallback(BuildContext context) {
    if (isVideoCall) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            username: username,
            avatarUrl: avatarUrl,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            username: username,
            avatarUrl: avatarUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey[300],
            child: avatarUrl.startsWith('https')
                ? null
                : const Icon(Icons.person, color: Colors.white),
          ),
          
          const SizedBox(width: 12),
          
          // Call info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isVideoCall ? Icons.videocam_off : Icons.phone_missed,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Missed ${isVideoCall ? 'video' : 'voice'} call',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'from $username',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Just now',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Callback button
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isVideoCall ? Icons.videocam : Icons.call,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (onCallback != null) {
                      onCallback!();
                    } else {
                      _makeCallback(context);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
              const SizedBox(height: 8),
              // Dismiss button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onDismiss ?? () {
                    // Dismiss notification
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget to show missed call notification in chat screen
class MissedCallBanner extends StatefulWidget {
  final String username;
  final String avatarUrl;
  final bool isVideoCall;
  final VoidCallback? onCallback;

  const MissedCallBanner({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.isVideoCall = false,
    this.onCallback,
  });

  @override
  State<MissedCallBanner> createState() => _MissedCallBannerState();
}

class _MissedCallBannerState extends State<MissedCallBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            widget.isVideoCall ? Icons.videocam_off : Icons.phone_missed,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missed ${widget.isVideoCall ? 'video' : 'voice'} call',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Tap to call back',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                _isVisible = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
