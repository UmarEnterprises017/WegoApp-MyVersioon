import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamCallback = void Function(String userId, MediaStream stream);
typedef UserCallback = void Function(String userId);

class WebRTCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔥 RENDERERS
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // Local stream
  MediaStream? _localStream;
  MediaStream? get localStream => _localStream;

  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  Map<String, MediaStream> get remoteStreams =>
      Map.unmodifiable(_remoteStreams);

  // ✅ CALLBACKS
  StreamCallback? onRemoteStreamAdded;
  StreamCallback? onRemoteStreamRemoved;
  UserCallback? onUserJoined;
  UserCallback? onUserLeft;
  void Function()? onLocalStreamReady;

  String? _roomId;
  String? _localUserId;

  final List<StreamSubscription> _subscriptions = [];

  // ✅ APNA TURN SERVER — connecting stuck problem fix
  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:global.relay.metered.ca:80',
        'username': 'ad2cbc228b6c4060be0bfe0e',
        'credential': 'Xrn4T/NZtb55w/gU',
      },
      {
        'urls': 'turn:global.relay.metered.ca:80?transport=tcp',
        'username': 'ad2cbc228b6c4060be0bfe0e',
        'credential': 'Xrn4T/NZtb55w/gU',
      },
      {
        'urls': 'turn:global.relay.metered.ca:443',
        'username': 'ad2cbc228b6c4060be0bfe0e',
        'credential': 'Xrn4T/NZtb55w/gU',
      },
      {
        'urls': 'turns:global.relay.metered.ca:443?transport=tcp',
        'username': 'ad2cbc228b6c4060be0bfe0e',
        'credential': 'Xrn4T/NZtb55w/gU',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  // ─────────────────────────────
  // INIT LOCAL STREAM
  // ─────────────────────────────
  Future<void> initLocalStream({
    bool video = true,
    bool audio = true,
  }) async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    final stream = await navigator.mediaDevices.getUserMedia({
      'video': video
          ? {
        'facingMode': 'user',
      }
          : false,
      'audio': audio,
    });

    _localStream = stream;
    localRenderer.srcObject = stream;

    onLocalStreamReady?.call();
  }

  // ─────────────────────────────
  // ✅ CREATE OR JOIN ROOM
  // ─────────────────────────────
  Future<void> createOrJoinRoom(String roomId, String userId) async {
    await _firestore.collection('rooms').doc(roomId).set({
      'createdAt': FieldValue.serverTimestamp(),
      'roomId': roomId,
      'status': 'active',
    }, SetOptions(merge: true));

    await joinRoom(roomId, userId);
  }

  // ─────────────────────────────
  // JOIN ROOM
  // ─────────────────────────────
  Future<void> joinRoom(String roomId, String userId) async {
    _roomId = roomId;
    _localUserId = userId;

    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .set({'userId': userId, 'joinedAt': FieldValue.serverTimestamp()});

    // ✅ Participants listener
    final participantsSub = _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        final otherId = change.doc.id;
        if (otherId == userId) continue;

        if (change.type == DocumentChangeType.added) {
          onUserJoined?.call(otherId);
          if (userId.compareTo(otherId) < 0) {
            await _createOffer(otherId);
          }
        } else if (change.type == DocumentChangeType.removed) {
          onUserLeft?.call(otherId);
          await _removePeer(otherId);
        }
      }
    });

    _subscriptions.add(participantsSub);

    // ✅ Signals listener
    final signalSub = _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('signals')
        .where('to', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;

        final data = change.doc.data()!;
        final from = data['from'] as String;

        switch (data['type']) {
          case 'offer':
            await _handleOffer(from, data['sdp'] as String);
            break;
          case 'answer':
            await _handleAnswer(from, data['sdp'] as String);
            break;
          case 'candidate':
            await _handleCandidate(from, data);
            break;
        }

        await change.doc.reference.delete();
      }
    });

    _subscriptions.add(signalSub);
  }

  // ─────────────────────────────
  // PEER CONNECTION
  // ─────────────────────────────
  Future<RTCPeerConnection> _getOrCreatePeerConnection(
      String remoteId) async {
    if (_peerConnections.containsKey(remoteId)) {
      return _peerConnections[remoteId]!;
    }

    final pc = await createPeerConnection(_iceConfig);

    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await pc.addTrack(track, _localStream!);
      }
    }

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        _remoteStreams[remoteId] = stream;
        remoteRenderer.srcObject = stream;
        onRemoteStreamAdded?.call(remoteId, stream);
      }
    };

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendSignal(remoteId, {
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _removePeer(remoteId);
        onUserLeft?.call(remoteId);
      }
    };

    _peerConnections[remoteId] = pc;
    return pc;
  }

  // ─────────────────────────────
  // OFFER / ANSWER
  // ─────────────────────────────
  Future<void> _createOffer(String remoteId) async {
    final pc = await _getOrCreatePeerConnection(remoteId);

    final offer = await pc.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await pc.setLocalDescription(offer);

    await _sendSignal(remoteId, {
      'type': 'offer',
      'sdp': offer.sdp,
    });
  }

  Future<void> _handleOffer(String remoteId, String sdp) async {
    final pc = await _getOrCreatePeerConnection(remoteId);

    await pc.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );

    final answer = await pc.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await pc.setLocalDescription(answer);

    await _sendSignal(remoteId, {
      'type': 'answer',
      'sdp': answer.sdp,
    });
  }

  Future<void> _handleAnswer(String remoteId, String sdp) async {
    final pc = _peerConnections[remoteId];
    if (pc == null) return;

    await pc.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
  }

  Future<void> _handleCandidate(
      String remoteId, Map<String, dynamic> data) async {
    final pc = _peerConnections[remoteId];
    if (pc == null) return;

    await pc.addCandidate(RTCIceCandidate(
      data['candidate'] as String,
      data['sdpMid'] as String?,
      data['sdpMLineIndex'] as int?,
    ));
  }

  // ─────────────────────────────
  // SEND SIGNAL
  // ─────────────────────────────
  Future<void> _sendSignal(
      String toId, Map<String, dynamic> payload) async {
    await _firestore
        .collection('rooms')
        .doc(_roomId)
        .collection('signals')
        .add({
      'from': _localUserId,
      'to': toId,
      'timestamp': FieldValue.serverTimestamp(),
      ...payload,
    });
  }

  // ─────────────────────────────
  // REMOVE PEER
  // ─────────────────────────────
  Future<void> _removePeer(String remoteId) async {
    final pc = _peerConnections.remove(remoteId);
    await pc?.close();

    final stream = _remoteStreams.remove(remoteId);

    if (stream != null) {
      onRemoteStreamRemoved?.call(remoteId, stream);
      stream.dispose();
    }
  }

  // ─────────────────────────────
  // CONTROLS
  // ─────────────────────────────
  void toggleMic() {
    final track = _localStream?.getAudioTracks().firstOrNull;
    if (track != null) {
      track.enabled = !track.enabled;
    }
  }

  void toggleCamera() {
    final track = _localStream?.getVideoTracks().firstOrNull;
    if (track != null) {
      track.enabled = !track.enabled;
    }
  }

  Future<void> switchCamera() async {
    final track = _localStream?.getVideoTracks().firstOrNull;
    if (track != null) {
      await Helper.switchCamera(track);
    }
  }

  bool get isMicEnabled =>
      _localStream?.getAudioTracks().firstOrNull?.enabled ?? false;

  bool get isCameraEnabled =>
      _localStream?.getVideoTracks().firstOrNull?.enabled ?? false;

  // ─────────────────────────────
  // LEAVE ROOM
  // ─────────────────────────────
  Future<void> leaveRoom() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    for (final id in _peerConnections.keys.toList()) {
      await _removePeer(id);
    }

    _localStream?.getTracks().forEach((t) => t.stop());
    await _localStream?.dispose();
    _localStream = null;

    await localRenderer.dispose();
    await remoteRenderer.dispose();

    if (_roomId != null && _localUserId != null) {
      await _firestore
          .collection('rooms')
          .doc(_roomId)
          .collection('participants')
          .doc(_localUserId)
          .delete();
    }

    _roomId = null;
    _localUserId = null;
  }
}