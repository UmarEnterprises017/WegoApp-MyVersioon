import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VoiceCallScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;

  const VoiceCallScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with TickerProviderStateMixin {
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  bool _isCallEnded = false;
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
      backgroundColor: const Color(0xFF075E54), // WhatsApp green
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
                    'Voice call',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Avatar with pulse animation when ringing
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isCallEnded ? 1.0 : _pulseAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.avatarUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, size: 80, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Username and status
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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

                  // Call duration
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

                  const SizedBox(height: 60),

                  // Control buttons
                  if (!_isCallEnded) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                                  _isSpeakerOn ? Icons.speaker : Icons.speaker_outlined,
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

                        // Add call button
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_call,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  // Add another person to call
                                  HapticFeedback.lightImpact();
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add call',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),

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
          ],
        ),
      ),
    );
  }
}
