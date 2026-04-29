import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// ─── WebRTC + Firebase Signaling Service ─────────────────────────────────────
class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  Function(MediaStream)? onLocalStream;
  Function(MediaStream)? onRemoteStream;
  Function(String)? onConnectionStateChange;
  Function()? onCallEnded;

  // ICE Servers config
  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  String get _myUid => _auth.currentUser?.uid ?? 'unknown';

  // ── Call Room ID banana ──
  String _roomId(String remoteUid) {
    final ids = [_myUid, remoteUid]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ── PeerConnection banana ──
  Future<void> _createPeerConnection() async {
    peerConnection = await createPeerConnection(_iceConfig);

    // Local stream add karo
    localStream?.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    // Remote stream handle karo
    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        onRemoteStream?.call(remoteStream!);
      }
    };

    // Connection state changes
    peerConnection!.onConnectionState = (state) {
      onConnectionStateChange?.call(state.name);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        onCallEnded?.call();
      }
    };
  }

  // ── Local Media Stream lena ──
  Future<void> initLocalStream({bool videoEnabled = true}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': videoEnabled
          ? {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      }
          : false,
    };

    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream?.call(localStream!);
  }

  // ── CALLER: Call start karo ──
  Future<void> startCall({
    required String remoteUid,
    required bool isVideoCall,
  }) async {
    await initLocalStream(videoEnabled: isVideoCall);
    await _createPeerConnection();

    final roomId = _roomId(remoteUid);
    final roomRef = _firestore.collection('calls').doc(roomId);

    // ICE candidates store karo
    peerConnection!.onIceCandidate = (candidate) async {
      await roomRef
          .collection('callerCandidates')
          .add(candidate.toMap());
    };

    // Offer banao
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    // Firestore mein save karo
    await roomRef.set({
      'offer': {'type': offer.type, 'sdp': offer.sdp},
      'callerId': _myUid,
      'calleeId': remoteUid,
      'isVideoCall': isVideoCall,
      'status': 'calling',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Answer ka wait karo
    roomRef.snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;

      if (peerConnection?.getRemoteDescription() == null &&
          data['answer'] != null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await peerConnection!.setRemoteDescription(answer);
      }

      if (data['status'] == 'ended') {
        onCallEnded?.call();
      }
    });

    // Callee ke ICE candidates listen karo
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final candidate = RTCIceCandidate(
            change.doc['candidate'],
            change.doc['sdpMid'],
            change.doc['sdpMLineIndex'],
          );
          peerConnection!.addCandidate(candidate);
        }
      }
    });
  }

  // ── CALLEE: Call receive karo ──
  Future<void> answerCall({
    required String callerUid,
    required bool isVideoCall,
  }) async {
    await initLocalStream(videoEnabled: isVideoCall);
    await _createPeerConnection();

    final roomId = _roomId(callerUid);
    final roomRef = _firestore.collection('calls').doc(roomId);

    // ICE candidates store karo
    peerConnection!.onIceCandidate = (candidate) async {
      await roomRef
          .collection('calleeCandidates')
          .add(candidate.toMap());
    };

    // Offer lao
    final roomData = (await roomRef.get()).data()!;
    final offer = RTCSessionDescription(
      roomData['offer']['sdp'],
      roomData['offer']['type'],
    );
    await peerConnection!.setRemoteDescription(offer);

    // Answer banao
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    // Firestore update karo
    await roomRef.update({
      'answer': {'type': answer.type, 'sdp': answer.sdp},
      'status': 'connected',
    });

    // Caller ke ICE candidates listen karo
    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final candidate = RTCIceCandidate(
            change.doc['candidate'],
            change.doc['sdpMid'],
            change.doc['sdpMLineIndex'],
          );
          peerConnection!.addCandidate(candidate);
        }
      }
    });

    // Status changes monitor karo
    roomRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      if (data['status'] == 'ended') {
        onCallEnded?.call();
      }
    });
  }

  // ── Call end karo ──
  Future<void> endCall(String remoteUid) async {
    final roomId = _roomId(remoteUid);
    final roomRef = _firestore.collection('calls').doc(roomId);

    // Firestore update
    try {
      await roomRef.update({'status': 'ended'});
    } catch (_) {}

    // Streams band karo
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;

    await remoteStream?.dispose();
    remoteStream = null;

    await peerConnection?.close();
    peerConnection = null;
  }

  // ── Mic toggle ──
  void toggleMic(bool enabled) {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  // ── Camera toggle ──
  void toggleCamera(bool enabled) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  // ── Camera flip (front/back) ──
  Future<void> flipCamera() async {
    final videoTracks = localStream?.getVideoTracks();
    if (videoTracks != null && videoTracks.isNotEmpty) {
      await Helper.switchCamera(videoTracks.first);
    }
  }

  // ── Incoming call check karo ──
  Stream<DocumentSnapshot> listenForIncomingCall(String myUid) {
    return _firestore
        .collection('calls')
        .where('calleeId', isEqualTo: myUid)
        .where('status', isEqualTo: 'calling')
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }
}