import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioPath;
  final bool isMine;
  final bool isViewOnce;
  final bool isPlayed;
  final Duration duration;
  final VoidCallback? onPlayed;
  final VoidCallback? onViewOnceOpened;

  const VoiceMessagePlayer({
    super.key,
    required this.audioPath,
    required this.isMine,
    this.isViewOnce = false,
    this.isPlayed = false,
    this.duration = Duration.zero,
    this.onPlayed,
    this.onViewOnceOpened,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  bool _hasOpenedViewOnce = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() {});
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() => _isPlaying = false);
        widget.onPlayed?.call();
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (widget.isViewOnce && !_hasOpenedViewOnce) {
      setState(() => _hasOpenedViewOnce = true);
      widget.onViewOnceOpened?.call();
      return;
    }

    setState(() => _isPlaying = !_isPlaying);
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isMine ? const Color(0xFF6B4EFF) : Colors.grey[300];
    final dotColor = widget.isPlayed ? Colors.blue : bubbleColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Play Button with dot indicator
          Stack(
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.isMine ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isMine ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                ),
              ),
              // Dot indicator
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform visualization (simplified)
                Container(
                  height: 30,
                  child: CustomPaint(
                    painter: WaveformPainter(
                      isPlaying: _isPlaying,
                      progress: widget.duration.inMilliseconds > 0
                          ? _currentPosition.inMilliseconds / widget.duration.inMilliseconds
                          : 0.0,
                      color: widget.isMine ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Time display
                Text(
                  '${_currentPosition.inSeconds}s / ${widget.duration.inSeconds}s',
                  style: TextStyle(
                    color: widget.isMine ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // View Once indicator
          if (widget.isViewOnce)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hasOpenedViewOnce ? 'Opened' : 'Once',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isPlaying;
  final double progress;
  final Color color;

  WaveformPainter({
    required this.isPlaying,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2;

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final barHeight = (i % 3 + 1) * 4.0 + (isPlaying ? (i % 2 == 0 ? 2 : -2) : 0);
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;

      if (i / barCount < progress) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + barHeight),
          activePaint,
        );
      } else {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + barHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying || oldDelegate.progress != progress;
  }
}
