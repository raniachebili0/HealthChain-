import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:health_chain/config/app_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorAvatar;

  const VideoCallScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorAvatar,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // WebRTC variables
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isConnected = false;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  String callStatus = 'Connecting...';
  String callDuration = '00:00:00';
  bool _isIncomingCall = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _connectSocket();
    _initCall();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    final socketUrl = AppConfig.apiBaseUrl.replaceAll(":3000", ":3001");
    print('Connecting to signaling server at: $socketUrl');
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('Connected to signaling server at $socketUrl');
      socket.emit('join', {'room': 'call_${widget.doctorId}'});
    });

    socket.on('offer', (data) async {
      print('Received offer');
      if (_peerConnection != null) {
        RTCSessionDescription description = RTCSessionDescription(
          data['sdp'],
          data['type'],
        );
        await _peerConnection!.setRemoteDescription(description);
        
        // Create answer
        RTCSessionDescription answer = await _peerConnection!.createAnswer({});
        await _peerConnection!.setLocalDescription(answer);
        
        socket.emit('answer', {
          'to': widget.doctorId,
          'type': answer.type,
          'sdp': answer.sdp,
        });
        
        setState(() {
          callStatus = 'Connected';
          _isConnected = true;
          _startTimer();
        });
      }
    });

    socket.on('answer', (data) async {
      print('Received answer');
      if (_peerConnection != null) {
        RTCSessionDescription description = RTCSessionDescription(
          data['sdp'],
          data['type'],
        );
        await _peerConnection!.setRemoteDescription(description);
        setState(() {
          callStatus = 'Connected';
          _isConnected = true;
          _startTimer();
        });
      }
    });

    socket.on('ice_candidate', (data) async {
      if (_peerConnection != null) {
        RTCIceCandidate candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
      }
    });

    socket.on('call_ended', (_) {
      _endCall();
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isConnected) {
        setState(() {
          _seconds++;
          callDuration = _formatDuration(_seconds);
        });
        _startTimer();
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _initCall() async {
    // Create peer connection
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
        {'url': 'stun:stun1.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration, {});

    // Setup media streams
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    try {
      _localStream = await navigator.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Add tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Set up event handlers
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        socket.emit('ice_candidate', {
          'to': widget.doctorId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {
          _isConnected = true;
        });
      };

      // Create and send offer if this is an outgoing call
      if (!_isIncomingCall) {
        RTCSessionDescription offer = await _peerConnection!.createOffer({});
        await _peerConnection!.setLocalDescription(offer);
        
        socket.emit('offer', {
          'to': widget.doctorId,
          'type': offer.type,
          'sdp': offer.sdp,
        });
      }

    } catch (e) {
      print('Error initializing call: $e');
      setState(() {
        callStatus = 'Failed to connect';
      });
    }
  }

  void _toggleMicrophone() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks()[0];
      setState(() {
        _isMicMuted = !_isMicMuted;
        audioTrack.enabled = !_isMicMuted;
      });
    }
  }

  void _toggleCamera() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks()[0];
      setState(() {
        _isCameraOff = !_isCameraOff;
        videoTrack.enabled = !_isCameraOff;
      });
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // In a real app, implement speaker toggle using device APIs
  }

  Future<void> _endCall() async {
    // Stop streams
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
    }

    // Close peer connection
    if (_peerConnection != null) {
      await _peerConnection!.close();
    }

    // Notify other party
    socket.emit('end_call', {'to': widget.doctorId});
    
    // Close socket
    socket.disconnect();

    // Go back
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video (remote user)
          _isConnected
              ? RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.doctorAvatar),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.doctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        callStatus,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

          // Local video (picture-in-picture)
          Positioned(
            right: 20,
            top: 50,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // Call duration and info
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    callDuration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (_isConnected) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Call with ${widget.doctorName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Swipe indicator
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white54,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Swipe back to menu',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera toggle
                    _buildControlButton(
                      icon: _isCameraOff
                          ? Icons.videocam_off
                          : Icons.videocam,
                      color: Colors.white,
                      backgroundColor: Colors.grey.shade800,
                      onPressed: _toggleCamera,
                    ),
                    
                    // End call button
                    _buildControlButton(
                      icon: Icons.call_end,
                      color: Colors.white,
                      backgroundColor: Colors.red,
                      onPressed: _endCall,
                      size: 60,
                    ),
                    
                    // Microphone toggle
                    _buildControlButton(
                      icon: _isMicMuted
                          ? Icons.mic_off
                          : Icons.mic,
                      color: Colors.white,
                      backgroundColor: Colors.grey.shade800,
                      onPressed: _toggleMicrophone,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }
} 