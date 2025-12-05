import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VoiceMessageRecorder extends StatefulWidget {
  final Function(String?) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceMessageRecorder({
    Key? key,
    required this.onRecordingComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  _VoiceMessageRecorderState createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasPermission = false;
  String? _filePath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _amplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _stopRecording(sendFile: false);
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _checkPermission();
      if (!_hasPermission) return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _filePath = path.join(tempDir.path, 'voice_message_$timestamp.m4a');

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _filePath!,
      );

      _amplitudeSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 300))
          .listen((amp) {
        setState(() {
          _amplitude = (amp.current + 60) / 60; // Normalize to 0-1 range
        });
      });

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording({bool sendFile = true}) async {
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();

    if (_isRecording) {
      try {
        await _audioRecorder.stop();
      } catch (e) {
        debugPrint('Error stopping recording: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }

    if (sendFile && _filePath != null) {
      widget.onRecordingComplete(_filePath);
    } else {
      widget.onRecordingComplete(null);
    }
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRecording ? 'Recording...' : 'Hold to record',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_isRecording)
                      Text(
                        _formatDuration(_recordingDuration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              _buildRecordButton(),
              const SizedBox(width: 8),
              if (_filePath != null && !_isRecording)
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => widget.onRecordingComplete(_filePath),
                ),
            ],
          ),
          if (_isRecording) _buildVisualizer(),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onLongPress: () => _stopRecording(),
      onLongPressStart: (_) => _startRecording(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: _isRecording ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          // Create a wave-like effect based on amplitude
          final height = 4 + (_amplitude * 16 * (1 - (index % 2) * 0.5));
          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }
}