import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:health_chain/config/api_config.dart';

class CallingScreen extends StatefulWidget {
  final String callId;
  final String remoteName;
  final String remoteAvatar;
  final String callType; // "audio" or "video"
  final bool isIncoming;
  final io.Socket? socket;

  const CallingScreen({
    Key? key,
    required this.callId,
    required this.remoteName,
    this.remoteAvatar = "assets/images/avatar.png",
    this.callType = "audio",
    this.isIncoming = false,
    this.socket,
  }) : super(key: key);

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isCallConnected = false;
  Timer? callTimer;
  int callDurationSeconds = 0;
  String callStatus = "Connecting...";
  
  @override
  void initState() {
    super.initState();
    
    // Initial haptic feedback for call awareness
    HapticFeedback.mediumImpact();
    
    // Set up call connection status
    if (widget.isIncoming) {
      setState(() {
        callStatus = "Connected";
        isCallConnected = true;
      });
      _startCallTimer();
    } else {
      // Wait for remote to accept the call
      _setupCallEventListeners();
      setState(() {
        callStatus = "Calling...";
      });
      
      // Auto end call if not connected after timeout
      Future.delayed(Duration(seconds: ApiConfig.CALL_TIMEOUT_SECONDS), () {
        if (!isCallConnected && mounted) {
          _endCall(reason: "No answer");
        }
      });
    }
  }
  
  void _setupCallEventListeners() {
    if (widget.socket == null) return;
    
    // Listen for call accepted
    widget.socket!.on('call_accepted', (data) {
      if (mounted && data['callId'] == widget.callId) {
        setState(() {
          callStatus = "Connected";
          isCallConnected = true;
        });
        _startCallTimer();
        HapticFeedback.mediumImpact();
      }
    });
    
    // Listen for call ended
    widget.socket!.on('call_ended', (data) {
      if (mounted && data['callId'] == widget.callId) {
        Navigator.of(context).pop("Call ended by remote user");
      }
    });
  }
  
  void _startCallTimer() {
    callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          callDurationSeconds++;
        });
      }
    });
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
    // Here you would implement actual audio muting logic
  }
  
  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    // Here you would implement actual speaker toggling logic
  }
  
  void _endCall({String reason = "Call ended"}) {
    // Cancel timer if running
    callTimer?.cancel();
    
    // Send call ended event if socket exists
    if (widget.socket != null && widget.socket!.connected) {
      widget.socket!.emit('end_call', {
        'callId': widget.callId,
        'reason': reason
      });
    }
    
    // Exit the screen
    Navigator.of(context).pop(reason);
  }
  
  @override
  void dispose() {
    callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Top status bar with duration
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                isCallConnected ? _formatDuration(callDurationSeconds) : callStatus,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Expanded area with caller info
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(widget.remoteAvatar),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.remoteName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.callType == "video" ? "Video Call" : "Audio Call",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom control buttons
            Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  IconButton(
                    icon: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: isMuted ? Colors.red : Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleMute,
                  ),
                  
                  // End call button
                  ElevatedButton(
                    onPressed: () => _endCall(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  // Speaker button
                  IconButton(
                    icon: Icon(
                      isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      color: isSpeakerOn ? Colors.blue : Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleSpeaker,
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