import 'webrtc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class EnhancedVideoCallScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;

  const EnhancedVideoCallScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<EnhancedVideoCallScreen> createState() => _EnhancedVideoCallScreenState();
}

class _EnhancedVideoCallScreenState extends State<EnhancedVideoCallScreen> with TickerProviderStateMixin {
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isCallEnded = false;
  bool _isFrontCamera = true;
  bool _isCallAnswered = false;
  bool _isMinimized = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _currentFilterIndex = 0;
  bool _showFilterSearch = false;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'icon': Icons.filter_none},
    {'name': 'Beauty', 'icon': Icons.face},
    {'name': 'Hide Face', 'icon': Icons.visibility_off},
    {'name': 'Background', 'icon': Icons.landscape},
    {'name': 'Spiderman', 'icon': Icons.stars},
    {'name': 'Vintage', 'icon': Icons.auto_awesome},
    {'name': 'B&W', 'icon': Icons.brightness_6},
    {'name': 'Warm', 'icon': Icons.wb_sunny},
    {'name': 'Cool', 'icon': Icons.ac_unit},
    {'name': 'Sepia', 'icon': Icons.auto_awesome},
  ];

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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, _isCallAnswered);
      }
    });
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    HapticFeedback.lightImpact();
  }

  void _showContactList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add to call',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
                    ),
                    title: Text('Contact $index', style: TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: Icon(Icons.add_call, color: Colors.green),
                      onPressed: () {
                        Navigator.pop(context);
                        _initiateGroupCall('Contact $index');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initiateGroupCall(String contactName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adding $contactName to call...')),
    );
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
    if (_isMinimized) {
      return _buildMinimizedView();
    }

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
                    onPressed: _toggleMinimize,
                  ),
                  const Spacer(),
                  Text(
                    'Video call',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    onPressed: _showContactList,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Background (remote video or self video before call answered)
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
                                      _isCallAnswered ? widget.avatarUrl : 'https://i.pravatar.cc/150?img=1',
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
                                  _isCallAnswered ? widget.username : 'You',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isCallEnded ? 'Call ended' : (_isCallAnswered ? 'Connected' : 'Ringing...'),
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

                  // Local video preview (small window when call answered, full screen before)
                  if (!_isVideoOff && !_isCallEnded)
                    Positioned(
                      top: _isCallAnswered ? 80 : 0,
                      right: _isCallAnswered ? 20 : 0,
                      left: _isCallAnswered ? null : 0,
                      bottom: _isCallAnswered ? null : 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: _isCallAnswered ? 100 : double.infinity,
                        height: _isCallAnswered ? 140 : double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_isCallAnswered ? 12 : 0),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_isCallAnswered ? 10 : 0),
                          child: Container(
                            color: Colors.grey[800],
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.white24,
                                    size: _isCallAnswered ? 40 : 80,
                                  ),
                                ),
                                // Filter overlay
                                if (_currentFilterIndex > 0)
                                  Container(
                                    color: _getFilterColor(_currentFilterIndex).withOpacity(0.3),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Filter bar (permanently visible)
                  Positioned(
                    right: 0,
                    top: 100,
                    bottom: 200,
                    child: Container(
                      width: 70,
                      child: ListView.builder(
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() => _currentFilterIndex = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: _currentFilterIndex == index
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                filter['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Filter search icon (permanently visible)
                  Positioned(
                    right: 20,
                    top: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _showFilterSearchDialog,
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
                                _ControlButton(
                                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                                  label: _isMuted ? 'Unmute' : 'Mute',
                                  isActive: _isMuted,
                                  onPressed: () {
                                    setState(() => _isMuted = !_isMuted);
                                    HapticFeedback.lightImpact();
                                  },
                                ),

                                // Video button
                                _ControlButton(
                                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                                  label: _isVideoOff ? 'Video On' : 'Video Off',
                                  isActive: _isVideoOff,
                                  onPressed: () {
                                    setState(() => _isVideoOff = !_isVideoOff);
                                    HapticFeedback.lightImpact();
                                  },
                                ),

                                // Switch camera button
                                _ControlButton(
                                  icon: Icons.flip_camera_ios,
                                  label: 'Flip',
                                  isActive: false,
                                  onPressed: _switchCamera,
                                ),

                                // Speaker button
                                _ControlButton(
                                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                                  label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                                  isActive: _isSpeakerOn,
                                  onPressed: () {
                                    setState(() => _isSpeakerOn = !_isSpeakerOn);
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // End call button
                            GestureDetector(
                              onTap: _endCall,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text(
                                    'Call ended',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _formatDuration(_callDuration),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimizedView() {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Video preview
          Positioned.fill(
            child: Container(
              color: Colors.grey[800],
              child: const Icon(Icons.videocam, color: Colors.white24, size: 40),
            ),
          ),
          // Expand button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _toggleMinimize,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_full, color: Colors.white, size: 16),
              ),
            ),
          ),
          // End call button
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          // Duration
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _formatDuration(_callDuration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Search Filters', style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search filters...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getFilterColor(int index) {
    final colors = [
      Colors.transparent,
      Colors.pink.withOpacity(0.2),
      Colors.black.withOpacity(0.5),
      Colors.blue.withOpacity(0.3),
      Colors.red.withOpacity(0.3),
      Colors.brown.withOpacity(0.3),
      Colors.grey.withOpacity(0.5),
      Colors.orange.withOpacity(0.2),
      Colors.cyan.withOpacity(0.2),
      Colors.amber.withOpacity(0.3),
    ];
    return colors[index % colors.length];
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? Colors.white.withOpacity(0.3) 
                : Colors.white.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
