// DoctorConsultationScreen.dart (NEW FILE - Based on recorder_session_screen.dart)

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as web_html;


// Color constants from doctor flow (re-using kPrimaryColor)
const Color kPrimaryColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);

// --- Status Enum for UI State ---
enum RecorderStatus { ready, recording, disposing }

// --- Data Model (Unchanged) ---
class RecordingItem {
  final String id;
  final String pathOrUrl;
  final String name;
  final DateTime date;
  final Duration duration;
  final bool isCallRecording;

  RecordingItem({
    required this.id,
    required this.pathOrUrl,
    required this.name,
    required this.date,
    required this.duration,
    this.isCallRecording = false,
  });

  String get formattedDate {
    return DateFormat('dd/MM/yy HH:mm').format(date);
  }

  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayName {
    return name;
  }
}

// --- Screen State: Dedicated for Doctor Consultation ---
class DoctorConsultationScreen extends StatefulWidget {
  // Required parameters from the UpcomingAppointmentsScreen
  final String patientName;
  final String appointmentId;
  final String consultationType;

  const DoctorConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentId,
    required this.consultationType,
  });

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  // *** Voice Recorder State Management (from recorder_session_screen.dart) ***
  late AudioRecorder _audioRecorder;
  late AudioPlayer _player;

  RecorderStatus _recorderStatus = RecorderStatus.ready;

  bool _isPlaying = false;
  String? _currentlyPlayingId;
  List<RecordingItem> _recordings = [];
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Duration _playbackPosition = Duration.zero;
  Duration? _currentPlayingDuration;
  bool _isCallRecordingMode = false;
  bool _isLoading = false;
  int _recordingCounter = 1;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _amplitude = 0.0;

  String _permanentRecordingsPath = '';

  @override
  void initState() {
    super.initState();
    _initAudioObjects();
    _initApp();
  }

  @override
  void dispose() {
    _disposeAudioObjects();
    _player.dispose();
    super.dispose();
  }

  // --- Core Audio Logic (Unchanged from recorder_session_screen.dart) ---
  void _initAudioObjects() {
    _audioRecorder = AudioRecorder();
    _player = AudioPlayer();
  }

  Future<void> _disposeAudioObjects() async {
    await _cancelAmplitudeStream();
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    if (!kIsWeb) {
      await _audioRecorder.dispose();
    }
  }

  Future<void> _initApp() async {
    setState(() {
      _isLoading = true;
    });

    if (!kIsWeb) {
      await _checkPermissions();
      await _initPermanentDirectory();
      await _loadExistingRecordings();
    }

    _setupPlayerListeners();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initPermanentDirectory() async {
    if (kIsWeb) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${appDir.path}/app_recordings');

      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      _permanentRecordingsPath = recordingsDir.path;
    } catch (e) {
      print("Error initializing directory: $e");
      if (mounted) _showSnackBar('File system error. Cannot reliably save recordings.');
    }
  }

  Future<void> _checkPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus.isDenied) {
      if (mounted) _showSnackBar('Microphone permission denied. Cannot record audio.');
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    }
  }

  Future<void> _loadExistingRecordings() async {
    try {
      if (kIsWeb || _permanentRecordingsPath.isEmpty) return;

      final recordingsDir = Directory(_permanentRecordingsPath);

      if (!await recordingsDir.exists()) {
        return;
      }

      List<RecordingItem> loadedRecordings = [];
      final files = await recordingsDir.list().where((entity) {
        final name = entity.path.split('/').last.toLowerCase();
        return name.endsWith('.m4a');
      }).toList();

      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final duration = await _getAudioDuration(file.path);
          final fileName = file.path.split(Platform.pathSeparator).last;

          loadedRecordings.add(RecordingItem(
            id: '${stat.modified.millisecondsSinceEpoch}',
            pathOrUrl: file.path,
            name: fileName.replaceAll('.m4a', '').replaceAll('_', ' '),
            date: stat.modified,
            duration: duration,
            isCallRecording: fileName.startsWith('call_'),
          ));
        }
      }

      loadedRecordings.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _recordings = loadedRecordings;
        _recordingCounter = loadedRecordings.length + 1;
      });

    } catch (e) {
      print('Error loading recordings: $e');
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    try {
      final player = AudioPlayer();
      if (kIsWeb) {
        await player.setSource(UrlSource(path));
      } else {
        await player.setSource(DeviceFileSource(path));
      }
      final duration = await player.getDuration();
      player.dispose();
      return duration ?? const Duration(seconds: 0);
    } catch (e) {
      return const Duration(seconds: 0);
    }
  }

  void _setupPlayerListeners() {
    _player.onPlayerStateChanged.listen((PlayerState state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing || state == PlayerState.paused;
      });

      if (state == PlayerState.completed) {
        setState(() {
          _playbackPosition = Duration.zero;
          _currentlyPlayingId = null;
          _isPlaying = false;
        });
      }
    });

    _player.onDurationChanged.listen((Duration duration) {
      if (!mounted) return;
      setState(() {
        _currentPlayingDuration = duration;
      });
    });

    _player.onPositionChanged.listen((Duration position) {
      if (!mounted) return;
      setState(() {
        _playbackPosition = position;
      });
    });
  }

  Future<void> _cancelAmplitudeStream() async {
    if (_amplitudeSubscription != null) {
      try {
        await _amplitudeSubscription?.cancel();
      } catch(e) {
        print("Amplitude stream cancel error: $e");
      }
      _amplitudeSubscription = null;
    }
  }

  // --- MODIFIED: Uses patientName and appointmentId in the path ---
  Future<String> _getRecordingPath() async {
    // Sanitize patient name for file system safety
    final cleanPatientName = widget.patientName.replaceAll(RegExp(r'[^\w\s\-]'), '');
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Naming convention: ApptID_PatientName_Timestamp_Type.m4a
    final baseFileName = '${widget.appointmentId}_${cleanPatientName}_$timestamp';
    final fileName = '${baseFileName}${_isCallRecordingMode ? '_CALL' : '_DICTATION'}.m4a';

    if (kIsWeb) {
      return fileName;
    }

    if (_permanentRecordingsPath.isEmpty) {
      await _initPermanentDirectory();
    }

    return '$_permanentRecordingsPath${Platform.pathSeparator}$fileName';
  }

  // --- START Recording (Unchanged logic, uses new _getRecordingPath) ---
  Future<void> _startRecording({bool isCallRecording = false}) async {
    if (_recorderStatus != RecorderStatus.ready || _isLoading) {
      _showSnackBar('System busy. Wait for finalization or stop the current recording.');
      return;
    }

    await _disposeAudioObjects();
    _initAudioObjects();

    try {
      if (!kIsWeb) {
        await _checkPermissions();
        if (!await Permission.microphone.isGranted) return;
      }

      if (_isPlaying) await _player.stop();

      setState(() {
        _isCallRecordingMode = isCallRecording;
        _recorderStatus = RecorderStatus.recording;
      });

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 48000,
        numChannels: 2,
      );

      final path = await _getRecordingPath();

      final isRecording = await _audioRecorder.isRecording();
      if (isRecording) {
        throw Exception("Recorder failed to stop cleanly, force reset failed.");
      }

      await _audioRecorder.start(config, path: path);

      _amplitudeSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amplitude) {
        if (!mounted) return;
        setState(() {
          _amplitude = amplitude.current;
        });
      },
          onError: (e) {
            print("Amplitude Stream Error: $e");
            _amplitudeSubscription = null;
          });

      setState(() {
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    } catch (e) {
      print('Start recording error: $e');
      _showSnackBar('Failed to start recording: ${e.toString()}');
      if (mounted) setState(() => _recorderStatus = RecorderStatus.ready);
    }
  }

  // --- STOP Recording (Modified to use patientName in the displayed recording name) ---
  Future<void> _stopRecording() async {
    if (_recorderStatus != RecorderStatus.recording) return;

    if (mounted) setState(() => _recorderStatus = RecorderStatus.disposing);

    try {
      if (!await _audioRecorder.isRecording()) return;

      _recordingTimer?.cancel();
      await _cancelAmplitudeStream();

      final pathOrUrl = await _audioRecorder.stop();

      await _disposeAudioObjects();
      _initAudioObjects();

      setState(() {
        _amplitude = 0.0;
      });

      if (pathOrUrl != null && pathOrUrl.isNotEmpty) {
        final now = DateTime.now();
        final recordingNumber = _recordingCounter++;

        final duration = _recordingDuration.inSeconds > 0
            ? _recordingDuration
            : await _getAudioDuration(pathOrUrl);

        // MODIFIED: Use the patient name in the recording title for easy identification
        String recordingName = _isCallRecordingMode ?
        'Call: ${widget.patientName} #$recordingNumber' :
        'Session: ${widget.patientName} #$recordingNumber';

        final newRecording = RecordingItem(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          pathOrUrl: pathOrUrl,
          name: recordingName,
          date: now,
          duration: duration,
          isCallRecording: _isCallRecordingMode,
        );

        if (mounted) {
          setState(() {
            _recordings.insert(0, newRecording);
          });
        }

        final saveMessage = kIsWeb
            ? 'Recording saved. Tap Download to save to your computer.'
            : 'Recording saved successfully to app storage. Use "Download" to save to system folder.';

        _showSnackBar(saveMessage);

      } else {
        _showSnackBar('Recording was not saved properly.');
      }

    } catch (e) {
      print('Stop recording error: $e');
      _showSnackBar('Failed to save recording: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCallRecordingMode = false;
          _recorderStatus = RecorderStatus.ready;
        });
      }
    }
  }

  // --- Other Utility Functions (Download, Playback, Delete, etc. - Unchanged) ---
  Future<void> _downloadRecording(RecordingItem recording) async {
    try {
      final sanitizedFilename = recording.name.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
      final filenameWithExtension = '$sanitizedFilename.m4a';

      if (kIsWeb) {
        final url = recording.pathOrUrl;
        if (!url.startsWith('blob:')) {
          _showSnackBar('Error: Not a valid web recording (missing blob URL).');
          return;
        }
        final anchor = web_html.AnchorElement(href: url)
          ..setAttribute('download', filenameWithExtension)
          ..click();
        web_html.Url.revokeObjectUrl(url);
        _showSnackBar('✅ Download initiated! Check your browser\'s downloads folder.');
        return;
      }

      final sourceFile = File(recording.pathOrUrl);
      if (!await sourceFile.exists()) {
        _showSnackBar('Error: Internal file not found.');
        return;
      }

      Directory? targetDir;
      String dirName = '';
      targetDir = await getDownloadsDirectory();
      if (targetDir != null) {
        dirName = 'Downloads';
      } else {
        targetDir = await getApplicationDocumentsDirectory();
        if (targetDir != null) {
          dirName = 'Documents (App Storage)';
        }
      }

      if (targetDir == null) {
        _showSnackBar('Error: Could not access system Downloads or Documents folder.');
        return;
      }
      final targetPath = '${targetDir.path}${Platform.pathSeparator}$filenameWithExtension';
      await targetDir.create(recursive: true);
      final targetFile = await sourceFile.copy(targetPath);
      _showSnackBar('✅ Download saved to the system\'s **$dirName**! Path: ${targetFile.path}');
    } catch (e) {
      print('Download error: $e');
      if (e.toString().contains('Permission denied')) {
        _showSnackBar('🛑 File permission denied! Check app/system settings.');
      } else {
        _showSnackBar('Failed to download file: ${e.toString()}');
      }
    }
  }

  Future<void> _playRecording(RecordingItem recording) async {
    try {
      if (_currentlyPlayingId == recording.id && _player.state == PlayerState.paused) {
        await _resumePlayback();
        return;
      }
      if (_isPlaying) {
        await _player.stop();
      }
      if (mounted) {
        setState(() {
          _currentlyPlayingId = recording.id;
          _playbackPosition = Duration.zero;
        });
      }
      Source audioSource;
      if (kIsWeb) {
        audioSource = UrlSource(recording.pathOrUrl);
      } else {
        final file = File(recording.pathOrUrl);
        if (!await file.exists()) {
          _showSnackBar('File not found: ${recording.pathOrUrl}');
          if (mounted) setState(() => _currentlyPlayingId = null);
          return;
        }
        audioSource = DeviceFileSource(recording.pathOrUrl);
      }
      await _player.play(audioSource);
    } catch (e) {
      print('Play error: $e');
      _showSnackBar('Cannot play recording: ${e.toString()}');
    }
  }

  Future<void> _pausePlayback() async {
    await _player.pause();
  }

  Future<void> _resumePlayback() async {
    await _player.resume();
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    if (mounted) {
      setState(() {
        _playbackPosition = Duration.zero;
        _currentlyPlayingId = null;
        _isPlaying = false;
      });
    }
  }

  Future<void> _deleteRecording(RecordingItem recording) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Are you sure you want to delete this recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      if (!kIsWeb) {
        final file = File(recording.pathOrUrl);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (_currentlyPlayingId == recording.id) {
        await _stopPlayback();
      }
      if (mounted) {
        setState(() {
          _recordings.remove(recording);
        });
      }
      _showSnackBar('Recording deleted');
    } catch (e) {
      print('Delete error: $e');
      _showSnackBar('Failed to delete recording: ${e.toString()}');
    }
  }

  Future<void> _shareRecording(RecordingItem recording) async {
    try {
      if (kIsWeb) {
        _showSnackBar('Sharing is not supported on web. Use the Download option instead.');
        return;
      }
      final file = File(recording.pathOrUrl);
      if (!await file.exists()) {
        _showSnackBar('File not found');
        return;
      }
      final extension = recording.pathOrUrl.split('.').last;
      final mimeType = extension == 'm4a' ? 'audio/m4a' : 'audio/*';
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: 'Consultation Recording for ${widget.patientName}',
      );
    } catch (e) {
      print('Share error: $e');
      _showSnackBar('Failed to share: ${e.toString()}');
    }
  }


  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 7),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- MODIFIED build method to include Patient Context Header ---
  @override
  Widget build(BuildContext context) {
    final isRecording = _recorderStatus == RecorderStatus.recording;
    final isDisposing = _recorderStatus == RecorderStatus.disposing;
    final isButtonDisabled = _isLoading || isDisposing;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Consultation Session'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Patient/Session Header (Displays the specific patient's context)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${widget.patientName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${widget.consultationType} | Appt ID: ${widget.appointmentId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Recording Status Display
                      Row(
                        children: [
                          Icon(
                            isRecording ? Icons.fiber_manual_record : Icons.mic_none,
                            color: isRecording ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRecording
                                ? 'Recording in Progress...'
                                : 'Ready for Dictation',
                            style: TextStyle(
                              color: isRecording ? Colors.red : Colors.green.shade700,
                              fontWeight: isRecording ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      // Duration Timer
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isRecording ? kPrimaryColor : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amplitude Waveform (Simplified)
            Container(
              height: 40,
              color: kBackgroundColor,
              alignment: Alignment.center,
              child: isRecording
                  ? LinearProgressIndicator(
                value: _amplitude / 32767.0, // Max amplitude is 32767
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor.withOpacity(0.8)),
              )
                  : Text(
                'Session Recordings History',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),

            // Recording List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  final recording = _recordings[index];
                  final isCurrentPlaying = _currentlyPlayingId == recording.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    child: ListTile(
                      tileColor: isCurrentPlaying ? kPrimaryColor.withOpacity(0.1) : Colors.white,
                      leading: Icon(
                        isCurrentPlaying && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: kPrimaryColor,
                        size: 30,
                      ),
                      title: Text(
                        recording.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recorded: ${recording.formattedDate}'),
                          if (isCurrentPlaying)
                            LinearProgressIndicator(
                              value: (_playbackPosition.inSeconds > 0 && _currentPlayingDuration != null && _currentPlayingDuration!.inSeconds > 0)
                                  ? _playbackPosition.inSeconds / _currentPlayingDuration!.inSeconds
                                  : 0.0,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(recording.formattedDuration),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'download') {
                                _downloadRecording(recording);
                              } else if (value == 'share') {
                                _shareRecording(recording);
                              } else if (value == 'delete') {
                                _deleteRecording(recording);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'download',
                                child: Row(
                                  children: [
                                    Icon(Icons.download, size: 20),
                                    SizedBox(width: 8),
                                    Text('Download'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share, size: 20),
                                    SizedBox(width: 8),
                                    Text('Share'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        if (isCurrentPlaying) {
                          _pausePlayback();
                        } else {
                          _playRecording(recording);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isButtonDisabled
            ? null
            : (isRecording
            ? _stopRecording
            : () => _startRecording(isCallRecording: _isCallRecordingMode)),
        icon: Icon(isRecording
            ? Icons.stop
            : (_isCallRecordingMode ? Icons.call : Icons.mic)),
        label: Text(isRecording
            ? 'End Dictation'
            : (_isCallRecordingMode ? 'Record Call' : 'Start Dictation')),
        backgroundColor: isButtonDisabled ? Colors.grey : (isRecording
            ? Colors.red
            : kPrimaryColor),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}