import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health_chain/models/user.dart';

import 'call_handling_service.dart';

class AudioCallScreen extends StatefulWidget {
  final User remote;
  final bool isIncoming;
  final String? callId;

  const AudioCallScreen({
    Key? key,
    required this.remote,
    this.isIncoming = false,
    this.callId,
  }) : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  // UI state
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  String _callStatusText = 'Connecting...';
  
  // Call duration timer
  Timer? _callDurationTimer;
  int _callDurationSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  void _initialize() {
    if (widget.isIncoming) {
      setState(() {
        _callStatusText = 'Incoming call...';
      });
    } else {
      setState(() {
        _callStatusText = 'Calling...';
      });
    }
  }
  
  void _startCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationSeconds = 0;
    _callDurationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _callDurationTimer?.cancel();
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
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.blue.shade800),
                      ),
                      SizedBox(height: 20),
                      
                      Text(
                        widget.remote.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      Text(
                        _callStatusText,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      
                      if (_callDurationSeconds > 0)
                        Text(
                          _formatDuration(_callDurationSeconds),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: widget.isIncoming && _callDurationSeconds == 0
                      ? _buildIncomingCallControls()
                      : _buildActiveCallControls(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: Colors.red,
          child: Icon(Icons.call_end, color: Colors.white),
        ),
        
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _callStatusText = 'Connected';
            });
            _startCallDurationTimer();
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.call, color: Colors.white),
        ),
      ],
    );
  }
  
  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              _isMuted = !_isMuted;
            });
          },
          backgroundColor: _isMuted ? Colors.red : Colors.white,
          child: Icon(
            _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.white : Colors.blue.shade800,
          ),
        ),
        
        FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: Colors.red,
          child: Icon(Icons.call_end, color: Colors.white),
        ),
        
        FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              _isSpeakerOn = !_isSpeakerOn;
            });
          },
          backgroundColor: _isSpeakerOn ? Colors.blue.shade300 : Colors.white,
          child: Icon(
            _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            color: _isSpeakerOn ? Colors.white : Colors.blue.shade800,
          ),
        ),
      ],
    );
  }
}