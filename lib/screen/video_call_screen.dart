import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;

  const VideoCallScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with TickerProviderStateMixin {
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isCallEnded = false;
  bool _isSwitchCamera = false;
  bool _isCallAnswered = false; // Track if call was picked up
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _answerCall() {
    setState(() {
      _isCallAnswered = true;
    });
    HapticFeedback.lightImpact();
  }

  void _endCall() {
    setState(() {
      _isCallEnded = true;
    });
    _callTimer?.cancel();
    HapticFeedback.heavyImpact();

    // Return true if call was picked up, false if missed
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, _isCallAnswered);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                    onPressed: _endCall,
                  ),
                  const Spacer(),
                  Text(
                    'Video call',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      // Show more options
                    },
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Background (remote video or placeholder)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[900],
                    child: _isVideoOff
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      widget.avatarUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[600],
                                          child: const Icon(Icons.person, size: 60, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isCallEnded ? 'Call ended' : 'Ringing...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                                if (_callDuration.inSeconds > 0 && !_isCallEnded) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDuration(_callDuration),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white24,
                              size: 80,
                            ),
                          ),
                  ),

                  // Local video preview (small window)
                  if (!_isVideoOff && !_isCallEnded)
                    Positioned(
                      top: 80,
                      right: 20,
                      child: Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom controls
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          if (!_isCallEnded) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Mute button
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isMuted 
                                            ? Colors.white.withOpacity(0.3) 
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isMuted ? Icons.mic_off : Icons.mic,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isMuted = !_isMuted;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isMuted ? 'Unmute' : 'Mute',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                // Video button
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isVideoOff 
                                            ? Colors.white.withOpacity(0.3) 
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isVideoOff ? Icons.videocam_off : Icons.videocam,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isVideoOff = !_isVideoOff;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isVideoOff ? 'Video on' : 'Video off',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                // Switch camera button
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.flip_camera_ios,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isSwitchCamera = !_isSwitchCamera;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Flip',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                // Speaker button
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isSpeakerOn 
                                            ? Colors.white.withOpacity(0.3) 
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isSpeakerOn = !_isSpeakerOn;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Speaker',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],

                          // Answer/End call button
                          if (!_isCallAnswered)
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4CAF50), // Green for answer
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: _answerCall,
                              ),
                            )
                          else
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE53935), // Red for end call
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: _endCall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
