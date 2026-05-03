import 'package:flutter/material.dart';
import 'package:wego_marriage/screen/voice_call_screen.dart';
import 'package:wego_marriage/screen/video_call_screen.dart';

class CallLogMessage extends StatelessWidget {
  final bool isVideoCall;
  final bool isMissedCall;
  final bool isIncomingCall;
  final String username;
  final String avatarUrl;
  final String time;
  final Duration? duration;
  final bool isMine;
  final VoidCallback? onCallback;

  const CallLogMessage({
    super.key,
    required this.isVideoCall,
    required this.isMissedCall,
    required this.isIncomingCall,
    required this.username,
    required this.avatarUrl,
    required this.time,
    this.duration,
    this.isMine = false,
    this.onCallback,
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

  String _getCallTitle() {
    return isVideoCall ? 'Video call' : 'Voice call';
  }

  String _getCallSubtitle() {
    // Show "No answer" only when call is missed
    if (isMissedCall) {
      return 'No answer';
    }
    return '';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getCallIcon() {
    return isVideoCall ? Icons.videocam : Icons.call;
  }

  @override
  Widget build(BuildContext context) {
    // WhatsApp style: white bubble for received, green for sent
    final Color bubbleColor = isMine
        ? const Color(0xFFDCF8C6) // WhatsApp sent green
        : const Color(0xFFFFFFFF); // WhatsApp received white

    return GestureDetector(
      onTap: () {
        if (isMissedCall && onCallback != null) {
          onCallback!();
        } else {
          _makeCallback(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMine ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phone icon in white circle
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCallIcon(),
                  color: isMissedCall ? Colors.red : const Color(0xFF075E54),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              // Call info (title + optional subtitle)
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getCallTitle(),
                      style: const TextStyle(
                        color: Color(0xFF075E54),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                    if (_getCallSubtitle().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getCallSubtitle(),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Time at bottom right
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: isMine ? const Color(0xFF34B7F1) : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
