import 'package:wego_marriage/screen/service_connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wego_marriage/services/webrtc_service.dart';

class VoiceCallScreen extends StatefulWidget {
  final String remoteUserId;
  final String remoteUserName;
  final String remoteUserImage;

  const VoiceCallScreen({
    super.key,
    required this.remoteUserId,
    required this.remoteUserName,
    required this.remoteUserImage,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final WebRTCService _webrtc = WebRTCService();
  final String _localUserId = FirebaseAuth.instance.currentUser!.uid;

  bool _micOn = true;
  bool _speakerOn = false;
  bool _isConnecting = true;
  String _roomId = '';
  int _seconds = 0;
  late final Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(
        const Duration(seconds: 1), (i) => i + 1);
    _startCall();
  }

  String _buildRoomId() {
    final ids = [_localUserId, widget.remoteUserId]..sort();
    return '${ids[0]}_${ids[1]}_voice';
  }

  Future<void> _startCall() async {
    _roomId = _buildRoomId();

    await FirebaseFirestore.instance
        .collection('calls')
        .doc(_roomId)
        .set({
      'callerId': _localUserId,
      'receiverId': widget.remoteUserId,
      'type': 'voice',
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _webrtc.initLocalStream(video: false, audio: true);
    await _webrtc.createOrJoinRoom(_roomId, _localUserId);

    if (mounted) setState(() => _isConnecting = false);
  }

  Future<void> _endCall() async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(_roomId)
        .update({'status': 'ended'});

    await _webrtc.leaveRoom();
    if (mounted) Navigator.pop(context);
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _webrtc.leaveRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B1A4A), Color(0xFF3D0B1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Top Info ──
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(widget.remoteUserImage),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.remoteUserName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _isConnecting
                        ? const Text('Calling...',
                        style: TextStyle(color: Colors.white60, fontSize: 16))
                        : StreamBuilder<int>(
                      stream: _timerStream,
                      builder: (ctx, snap) {
                        return Text(
                          _formatTime(snap.data ?? 0),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Controls ──
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mic
                        _VoiceButton(
                          icon: _micOn ? Icons.mic : Icons.mic_off,
                          label: _micOn ? 'Mute' : 'Unmute',
                          color: Colors.white24,
                          onTap: () {
                            _webrtc.toggleMic();
                            setState(() => _micOn = !_micOn);
                          },
                        ),
                        // Speaker
                        _VoiceButton(
                          icon: _speakerOn
                              ? Icons.volume_up
                              : Icons.volume_off,
                          label: 'Speaker',
                          color: _speakerOn
                              ? Colors.white
                              : Colors.white24,
                          iconColor:
                          _speakerOn ? Colors.black : Colors.white,
                          onTap: () {
                            setState(() => _speakerOn = !_speakerOn);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // End call
                    GestureDetector(
                      onTap: _endCall,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 36),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _VoiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}