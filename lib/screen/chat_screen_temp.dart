          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    if (message.status == MsgStatus.sent) return const Icon(Icons.check, size: 14, color: Colors.grey);
    if (message.status == MsgStatus.delivered) return const Icon(Icons.done_all, size: 14, color: Colors.grey);
    return const Icon(Icons.done_all, size: 14, color: Colors.blue);
  }
}

// ── Voice Bubble ──────────────────────────────────────────────
class _VoiceBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  const _VoiceBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMine ? kTeal : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: isMine ? Colors.white : kPurple, size: 28),
          const SizedBox(width: 8),
          Flexible(child: _WaveformWidget(isMini: true)),
          const SizedBox(width: 8),
          Text(message.text?.replaceAll('Voice Message ', '') ?? '0:00', style: TextStyle(color: isMine ? Colors.white70 : Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Their Text Bubble ─────────────────────────────────────────
class _TheirTextBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final VoidCallback onLongPress;
  const _TheirTextBubble({required this.message, required this.isDark, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipOval(child: Image.network(message.avatarUrl ?? 'https://i.pravatar.cc/150', width: 32, height: 32, fit: BoxFit.cover)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
                  ),
                  child: message.type == MsgType.voice
                      ? _VoiceBubble(message: message, isMine: false)
                      : Text(message.text ?? '', style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                ),
                const SizedBox(height: 4),
                Text(message.time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TheirStickerMessage extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _TheirStickerMessage({required this.message, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipOval(child: Image.network(message.avatarUrl ?? 'https://i.pravatar.cc/150', width: 32, height: 32, fit: BoxFit.cover)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(message.imageUrl!, width: 120, height: 120),
                const SizedBox(height: 4),
                Text(message.time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TheirImageMessage extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onLongPress;
  final VoidCallback onSave;
  const _TheirImageMessage({required this.message, required this.onLongPress, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipOval(child: Image.network(message.avatarUrl ?? 'https://i.pravatar.cc/150', width: 32, height: 32, fit: BoxFit.cover)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(message.imageUrl!, height: 180, width: 200, fit: BoxFit.cover)),
                _SaveButton(onSave: onSave),
                const SizedBox(height: 4),
                Text(message.time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Save Button ───────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: kPurple.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPurple.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 14, color: kPurple),
            SizedBox(width: 4),
            Text('Save', style: TextStyle(fontSize: 12, color: kPurple, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Waveform Widget ───────────────────────────────────────────
class _WaveformWidget extends StatefulWidget {
  final bool isMini;
  const _WaveformWidget({this.isMini = false});

  @override
  State<_WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<_WaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.isMini ? 8 : 20, (i) {
          final h = (10 + (i % 4 + 1) * 6 * (_ctrl.value + 0.3)).clamp(4.0, 28.0);
          return Container(
            width: widget.isMini ? 2 : 3,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: kPurple.withOpacity(0.7), borderRadius: BorderRadius.circular(2)),
          );
        }),
      ),
    );
  }
}

// ── Typing Dot ────────────────────────────────────────────────
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});
  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _ctrl.repeat(reverse: true); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[500], shape: BoxShape.circle)),
      ),
    );
  }
}

// ── Message Info Screen ───────────────────────────────────────
class MessageInfoScreen extends StatelessWidget {
  final ChatMessage message;
  final String peerName;
  final String peerAvatar;
  const MessageInfoScreen({super.key, required this.message, required this.peerName, required this.peerAvatar});

  @override
  Widget build(BuildContext context) {
    final dt = message.dateTime ?? DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    final timeStr = message.time;

    return Scaffold(
      appBar: AppBar(backgroundColor: kPurple, title: const Text('Message Info', style: TextStyle(color: Colors.white)), leading: const BackButton(color: Colors.white)),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Preview of the message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: message.isMine ? kTeal.withOpacity(0.15) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MsgType.image && message.imageUrl != null)
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(message.imageUrl!, height: 140, fit: BoxFit.cover)),
                  if (message.type == MsgType.sticker && message.imageUrl != null)
                    Image.network(message.imageUrl!, height: 100),
                  if (message.text != null && message.text!.isNotEmpty)
                    Text(message.text!, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    '${_msgTypeLabel(message.type)} • ${message.isMine ? "Sent" : "Received"}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Details
          _InfoRow(icon: Icons.access_time, label: 'Time', value: timeStr),
          _InfoRow(icon: Icons.calendar_today, label: 'Date', value: dateStr),
          _InfoRow(icon: Icons.category_outlined, label: 'Type', value: _msgTypeLabel(message.type)),
          if (message.isMine) _InfoRow(icon: Icons.done_all, label: 'Status', value: _statusLabel(message.status), valueColor: message.status == MsgStatus.seen ? Colors.blue : Colors.grey),
          if (message.isStarred) _InfoRow(icon: Icons.star, label: 'Starred', value: 'Yes', iconColor: Colors.amber),
        ],
      ),
    );
  }

  String _msgTypeLabel(MsgType t) {
    switch (t) {
      case MsgType.text: return 'Text';
      case MsgType.image: return 'Image';
      case MsgType.sticker: return 'Sticker';
      case MsgType.voice: return 'Voice Message';
      case MsgType.video: return 'Video';
      case MsgType.gif: return 'GIF';
      default: return 'Message';
    }
  }

  String _statusLabel(MsgStatus s) {
    switch (s) {
      case MsgStatus.sent: return 'Sent ✓';
      case MsgStatus.delivered: return 'Delivered ✓✓';
      case MsgStatus.seen: return 'Seen ✓✓';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? kPurple),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor ?? Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}

// ── Forward Message Screen ────────────────────────────────────
class ForwardMessageScreen extends StatefulWidget {
  final ChatMessage message;
  const ForwardMessageScreen({super.key, required this.message});

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Ayesha', 'avatar': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Noori', 'avatar': 'https://i.pravatar.cc/150?img=2'},
    {'name': 'Hashim', 'avatar': 'https://i.pravatar.cc/150?img=3'},
    {'name': 'Sonia', 'avatar': 'https://i.pravatar.cc/150?img=4'},
    {'name': 'Zara', 'avatar': 'https://i.pravatar.cc/150?img=5'},
  ];
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPurple,
        leading: const BackButton(color: Colors.white),
        title: const Text('Forward to', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Message preview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.forward, color: kPurple, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message.text ?? '[${widget.message.type.name}]',
                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text('Recent chats', style: TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, i) {
                final c = _contacts[i];
                return CheckboxListTile(
                  value: _selected.contains(i),
                  onChanged: (v) { setState(() { if (v == true) _selected.add(i); else _selected.remove(i); }); },
                  secondary: ClipOval(child: Image.network(c['avatar']!, width: 44, height: 44, fit: BoxFit.cover)),
                  title: Text(c['name']!),
                  activeColor: kPurple,
                );
              },
            ),
          ),
          if (_selected.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text('Send to ${_selected.length} contact${_selected.length > 1 ? 's' : ''}'),
                    style: ElevatedButton.styleFrom(backgroundColor: kPurple, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message forwarded to ${_selected.length} contact(s)')));
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sticker Editor Screen ─────────────────────────────────────
class StickerEditorScreen extends StatefulWidget {
  final String stickerUrl;
  const StickerEditorScreen({super.key, required this.stickerUrl});

  @override
  State<StickerEditorScreen> createState() => _StickerEditorScreenState();
}

class _StickerEditorScreenState extends State<StickerEditorScreen> {
  double _scale = 1.0, _rotation = 0.0, _brightness = 1.0;
  String _overlayText = '';
  Color _borderColor = Colors.transparent;
  final TextEditingController _textCtrl = TextEditingController();
  final List<Color> _borderColors = [Colors.transparent, Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange, Colors.pink];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Edit Sticker', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sticker saved!'), backgroundColor: Colors.green)); },
            child: const Text('DONE', style: TextStyle(color: kPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 280, height: 280, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white10)),
                  Transform.scale(scale: _scale, child: Transform.rotate(angle: _rotation, child: Container(
                    decoration: BoxDecoration(border: Border.all(color: _borderColor, width: 4), borderRadius: BorderRadius.circular(12)),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix([_brightness,0,0,0,0,0,_brightness,0,0,0,0,0,_brightness,0,0,0,0,0,1,0]),
                      child: Image.network(widget.stickerUrl, width: 180, height: 180, fit: BoxFit.contain),
                    ),
                  ))),
                  if (_overlayText.isNotEmpty) Positioned(bottom: 40, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: Text(_overlayText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0F0F23), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderRow(Icons.zoom_in, 'Size', _scale, 0.5, 2.0, (v) => setState(() => _scale = v)),
                const SizedBox(height: 12),
                _buildSliderRow(Icons.rotate_right, 'Rotate', _rotation, -3.14, 3.14, (v) => setState(() => _rotation = v)),
                const SizedBox(height: 12),
                _buildSliderRow(Icons.brightness_6, 'Brightness', _brightness, 0.2, 2.0, (v) => setState(() => _brightness = v)),
                const SizedBox(height: 16),
                const Text('Border Color', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: _borderColors.map((c) {
                  final bool selected = _borderColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _borderColor = c),
                    child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: c == Colors.transparent ? Colors.white24 : c, shape: BoxShape.circle, border: selected ? Border.all(color: Colors.white, width: 2.5) : null), child: c == Colors.transparent ? const Icon(Icons.block, size: 16, color: Colors.white54) : null),
                  );
                }).toList())),
                const SizedBox(height: 16),
                const Text('Add Text', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: TextField(controller: _textCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Enter text on sticker...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none), onChanged: (v) => setState(() => _overlayText = v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(IconData icon, String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(children: [
      Icon(icon, color: Colors.white54, size: 18),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      Expanded(child: SliderTheme(
        data: SliderTheme.of(context).copyWith(activeTrackColor: kPurple, inactiveTrackColor: Colors.white12, thumbColor: kPurple, overlayColor: kPurple.withOpacity(0.2)),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      )),
    ]);
  }
}

// ── Voice Call Screen ─────────────────────────────────────────
class VoiceCallScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;
  const VoiceCallScreen({super.key, required this.username, required this.avatarUrl});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isConnected = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    // Simulate connecting after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
        });
      }
    });
  }

  @override
  void dispose() { _callTimer?.cancel(); super.dispose(); }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Background pattern
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(colors: [Color(0xFF1A1A3E), Color(0xFF0A0A1A)], radius: 1.5),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top row: minimize + add participant
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Minimize
                      _CallIconButton(icon: Icons.open_in_new, onTap: () => Navigator.pop(context), tooltip: 'Minimize'),
                      // Add participant
                      _CallIconButton(icon: Icons.person_add_outlined, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add participant'))), tooltip: 'Add'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Avatar
                ClipOval(child: Image.network(widget.avatarUrl, width: 120, height: 120, fit: BoxFit.cover)),
                const SizedBox(height: 20),
                Text(widget.username, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  _isConnected ? _formatDuration(_callDuration) : 'Calling...',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
                const Spacer(),
                // Controls row (same order as screenshot)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(40)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 3 dot
                        _CallButton(
                          icon: Icons.more_horiz,
                          onTap: () => _show3DotCallMenu(context),
                          bg: Colors.white.withOpacity(0.15),
                        ),
                        // Video (switch to video)
                        _CallButton(
                          icon: Icons.videocam_outlined,
                          onTap: () => _requestVideoSwitch(context),
                          bg: Colors.white.withOpacity(0.15),
                        ),
                        // Speaker
                        _CallButton(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_up_outlined,
                          onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                          bg: _isSpeakerOn ? kPurple : Colors.white.withOpacity(0.15),
                        ),
                        // Mute
                        _CallButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic_off_outlined,
                          onTap: () => setState(() => _isMuted = !_isMuted),
                          bg: _isMuted ? Colors.red.shade700 : Colors.white.withOpacity(0.15),
                        ),
                        // End call
                        _CallButton(icon: Icons.call_end, onTap: () => Navigator.pop(context), bg: Colors.red, size: 52),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _show3DotCallMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 8, bottom: 8), width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.message_outlined, color: Colors.white),
              title: const Text('Send Message', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_share_outlined, color: Colors.white),
              title: const Text('Share Screen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                if (!_isConnected) {
                  showDialog(context: context, builder: (c) => AlertDialog(
                    backgroundColor: const Color(0xFF2C2C2E),
                    content: const Text("You can't share your screen until another person joins the call.", style: TextStyle(color: Colors.white)),
                    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK', style: TextStyle(color: Colors.green)))],
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Screen sharing started')));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _requestVideoSwitch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Switch to Video Call?', style: TextStyle(color: Colors.white)),
        content: const Text('This will ask the other person to allow video.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requesting video call switch...')));
            },
            child: const Text('Request', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }
}

// ── Video Call Screen ─────────────────────────────────────────
class VideoCallScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;
  const VideoCallScreen({super.key, required this.username, required this.avatarUrl});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  bool _isConnected = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
        });
      }
    });
  }

  @override
  void dispose() { _callTimer?.cancel(); super.dispose(); }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (peer) background - show avatar if not connected
          _isConnected
              ? Container(color: const Color(0xFF1A1A2E), child: Center(child: ClipOval(child: Image.network(widget.avatarUrl, width: 120, height: 120, fit: BoxFit.cover))))
              : Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(widget.avatarUrl), fit: BoxFit.cover),
            ),
            child: Container(color: Colors.black54),
          ),
          // Local video preview (bottom right)
          if (_isConnected)
            Positioned(
              bottom: 120,
              right: 16,
              child: Container(
                width: 90,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(color: Colors.grey[700], child: const Icon(Icons.person, color: Colors.white54, size: 40)),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                // Top row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CallIconButton(icon: Icons.open_in_new, onTap: () => Navigator.pop(context), tooltip: 'Minimize'),
                      Column(
                        children: [
                          Text(widget.username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_isConnected ? _formatDuration(_callDuration) : 'Calling...', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        ],
                      ),
                      _CallIconButton(icon: Icons.person_add_outlined, onTap: () {}, tooltip: 'Add'),
                    ],
                  ),
                ),
                const Spacer(),
                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(40)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 3 dot
                        _CallButton(icon: Icons.more_horiz, onTap: () => _show3DotMenu(context), bg: Colors.white.withOpacity(0.2)),
                        // Flip camera
                        _CallButton(
                          icon: Icons.flip_camera_ios_outlined,
                          onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                          bg: Colors.white.withOpacity(0.2),
                        ),
                        // Speaker
                        _CallButton(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                          bg: _isSpeakerOn ? kPurple : Colors.white.withOpacity(0.2),
                        ),
                        // Mute
                        _CallButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic_off_outlined,
                          onTap: () => setState(() => _isMuted = !_isMuted),
                          bg: _isMuted ? Colors.red.shade700 : Colors.white.withOpacity(0.2),
                        ),
                        // End call
                        _CallButton(icon: Icons.call_end, onTap: () => Navigator.pop(context), bg: Colors.red, size: 52),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _show3DotMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 8, bottom: 8), width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.message_outlined, color: Colors.white),
              title: const Text('Send Message', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.screen_share_outlined, color: Colors.white),
              title: const Text('Share Screen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                if (!_isConnected) {
                  showDialog(context: context, builder: (c) => AlertDialog(
                    backgroundColor: const Color(0xFF2C2C2E),
                    content: const Text("You can't share your screen until another person joins the call.", style: TextStyle(color: Colors.white)),
                    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK', style: TextStyle(color: Colors.green)))],
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Screen sharing started')));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Call Button Widgets ───────────────────────────────────────
class _CallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bg;
  final double size;
  const _CallButton({required this.icon, required this.onTap, required this.bg, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _CallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _CallIconButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
