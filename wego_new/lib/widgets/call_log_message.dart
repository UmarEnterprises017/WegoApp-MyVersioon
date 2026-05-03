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
  final String receiverId;
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
    required this.receiverId,
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
            remoteUserId: receiverId,
            remoteUserName: username,
            remoteUserImage: avatarUrl,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            remoteUserId: receiverId,
            remoteUserName: username,
            remoteUserImage: avatarUrl,
          ),
        ),
      );
    }
  }

  String _getCallTitle() => isVideoCall ? 'Video call' : 'Voice call';

  String _getCallSubtitle() => isMissedCall ? 'No answer' : '';

  IconData _getCallIcon() => isVideoCall ? Icons.videocam : Icons.call;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isMine
        ? const Color(0xFFDCF8C6)
        : const Color(0xFFFFFFFF);

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
              color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(_getCallIcon(), color: isMissedCall ? Colors.red : const Color(0xFF075E54), size: 20),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getCallTitle(), style: const TextStyle(color: Color(0xFF075E54), fontWeight: FontWeight.w600, fontSize: 14.5)),
                    if (_getCallSubtitle().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(_getCallSubtitle(), style: const TextStyle(color: Colors.red, fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time, style: TextStyle(color: isMine ? const Color(0xFF34B7F1) : Colors.grey[500], fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}