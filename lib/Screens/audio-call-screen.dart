import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:health_chain/Screens/calling-screen.dart';

class AudioCallScreen extends CallingScreen {
  final String? peerId;
  final String? userId;

  AudioCallScreen({
    Key? key,
    String callId = '',
    this.peerId,
    this.userId,
    io.Socket? socket,
    String doctorName = 'Doctor',
    String doctorAvatar = 'assets/images/avatar.png',
  }) : super(
    key: key,
    callId: callId,
    remoteName: doctorName,
    remoteAvatar: doctorAvatar,
    callType: 'audio',
    isIncoming: peerId != null,
    socket: socket,
  );
} 