import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:health_chain/config/app_config.dart';

class AudioCallScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorAvatar;

  const AudioCallScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorAvatar,
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isConnected = false;
  bool _isMicMuted = false;
  bool _isSpeakerOn = false;
  String callStatus = 'Connecting...';
  String callDuration = '00:00:00';
  bool _isIncomingCall = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _initCall();
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

    // Setup media streams - audio only
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false,
    };

    try {
      _localStream = await navigator.getUserMedia(mediaConstraints);

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
        print('Remote audio stream added');
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
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade200,
              Colors.purple.shade300,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Doctor avatar
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.doctorAvatar,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                    _isConnected ? callDuration : callStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speaker toggle
                      _buildControlButton(
                        icon: _isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_down,
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                        onPressed: _toggleSpeaker,
                        hasBorder: true,
                      ),
                      const SizedBox(width: 24),
                      
                      // End call button
                      _buildControlButton(
                        icon: Icons.call_end,
                        color: Colors.white,
                        backgroundColor: Colors.red,
                        onPressed: _endCall,
                        size: 65,
                      ),
                      
                      const SizedBox(width: 24),
                      // Microphone toggle
                      _buildControlButton(
                        icon: _isMicMuted
                            ? Icons.mic_off
                            : Icons.mic,
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                        onPressed: _toggleMicrophone,
                        hasBorder: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    double size = 50,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: hasBorder ? Border.all(color: Colors.white, width: 1.5) : null,
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