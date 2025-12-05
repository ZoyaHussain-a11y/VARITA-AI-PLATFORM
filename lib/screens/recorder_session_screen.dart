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

// Import for navigation
import 'doctor_dashboard.dart';
import 'upcoming_appointments_screen.dart';
import 'message_screen.dart';
import 'total_patients_screen.dart';
import 'critical_cases_screen.dart';

// --- COLOR CONSTANTS FOR ATTRACTIVE UI (Pink Theme) ---
const Color kPrimaryPink = Color(0xFFC80469);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF7F7F7);
const Color kAccentRed = Color(0xFFC80469);
const Color kWhiteColor = Colors.white;

// --- Status Enum for UI State ---
enum RecorderStatus { ready, recording, disposing }

// --- Data Model ---
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

// --- Main Screen ---
class RecorderSessionScreen extends StatefulWidget {
  final String? patientName;
  final String? appointmentId;
  final String? consultationType;

  const RecorderSessionScreen({
    super.key,
    this.patientName,
    this.appointmentId,
    this.consultationType,
  });

  @override
  State<RecorderSessionScreen> createState() => _RecorderSessionScreenState();
}

class _RecorderSessionScreenState extends State<RecorderSessionScreen> {
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
  bool _isAppointmentContext = false;

  // Navigation Methods
  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DoctorDashboardScreen()),
    );
  }

  void _navigateToAppointments(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UpcomingAppointmentsScreen(),
      ),
    );
  }

  void _navigateToMessages(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MessageScreen()),
    );
  }

  void _navigateToCriticalCases(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CriticalCasesScreen()),
    );
  }

  void _navigateToPatients(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TotalPatientsScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _isAppointmentContext = widget.patientName != null;
    _initAudioObjects();
    _initApp();
  }

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
      if (kDebugMode) print("Error initializing directory: $e");
      if (mounted) {
        _showSnackBar('File system error. Cannot reliably save recordings.');
      }
    }
  }

  Future<void> _checkPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus.isDenied) {
      if (mounted) {
        _showSnackBar('Microphone permission denied. Cannot record audio.');
      }
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

          loadedRecordings.add(
            RecordingItem(
              id: '${stat.modified.millisecondsSinceEpoch}',
              pathOrUrl: file.path,
              name: fileName.replaceAll('.m4a', '').replaceAll('_', ' '),
              date: stat.modified,
              duration: duration,
              isCallRecording: fileName.startsWith('call_'),
            ),
          );
        }
      }

      loadedRecordings.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _recordings = loadedRecordings;
        _recordingCounter = loadedRecordings.length + 1;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading recordings: $e');
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
        _isPlaying =
            state == PlayerState.playing || state == PlayerState.paused;
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
      } catch (e) {
        if (kDebugMode) print("Amplitude stream cancel error: $e");
      }
      _amplitudeSubscription = null;
    }
  }

  Future<String> _getRecordingPath() async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = _isCallRecordingMode
        ? 'call_$timestamp.m4a'
        : 'recording_$timestamp.m4a';

    if (kIsWeb) {
      return fileName;
    }

    if (_permanentRecordingsPath.isEmpty) {
      await _initPermanentDirectory();
    }

    return '$_permanentRecordingsPath${Platform.pathSeparator}$fileName';
  }

  Future<void> _startRecording({bool isCallRecording = false}) async {
    if (_recorderStatus != RecorderStatus.ready || _isLoading) {
      _showSnackBar(
        'System busy. Wait for finalization or stop the current recording.',
      );
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
          .listen(
            (amplitude) {
              if (!mounted) return;
              setState(() {
                _amplitude = amplitude.current.clamp(0.0, 32767.0) / 32767.0;
              });
            },
            onError: (e) {
              if (kDebugMode) print("Amplitude Stream Error: $e");
              _amplitudeSubscription = null;
            },
          );

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
      if (kDebugMode) print('Start recording error: $e');
      _showSnackBar('Failed to start recording: ${e.toString()}');
      if (mounted) setState(() => _recorderStatus = RecorderStatus.ready);
    }
  }

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

        String recordingName;
        if (_isAppointmentContext) {
          recordingName = _isCallRecordingMode
              ? 'Call: ${widget.patientName} #$recordingNumber'
              : 'Session: ${widget.patientName} #$recordingNumber';
        } else {
          recordingName = _isCallRecordingMode
              ? 'Call Recording #$recordingNumber'
              : 'Voice Recording #$recordingNumber';
        }

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

        const saveMessage = kIsWeb
            ? 'Recording saved. Tap Download to save to your computer.'
            : 'Recording saved successfully to app storage. Use "Download" to save to system folder.';

        _showSnackBar(saveMessage);
      } else {
        _showSnackBar('Recording was not saved properly.');
      }
    } catch (e) {
      if (kDebugMode) print('Stop recording error: $e');
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

  Future<void> _downloadRecording(RecordingItem recording) async {
    try {
      final sanitizedFilename = recording.name
          .replaceAll(RegExp(r'[^\w\s\-]'), '_')
          .trim();
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

        _showSnackBar(
          '✅ Download initiated! Check your browser\'s downloads folder.',
        );
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
        _showSnackBar(
          'Error: Could not access system Downloads or Documents folder.',
        );
        return;
      }

      final targetPath =
          '${targetDir.path}${Platform.pathSeparator}$filenameWithExtension';
      await targetDir.create(recursive: true);

      await sourceFile.copy(targetPath);

      _showSnackBar('✅ Download saved to the system\'s **$dirName**!');
    } catch (e) {
      if (kDebugMode) print('Download error: $e');
      if (e.toString().contains('Permission denied')) {
        _showSnackBar('🛑 File permission denied! Check app/system settings.');
      } else {
        _showSnackBar('Failed to download file: ${e.toString()}');
      }
    }
  }

  Future<void> _playRecording(RecordingItem recording) async {
    try {
      if (_currentlyPlayingId == recording.id &&
          _player.state == PlayerState.paused) {
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
      if (kDebugMode) print('Play error: $e');
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
            child: const Text('Delete', style: TextStyle(color: kAccentRed)),
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
      if (kDebugMode) print('Delete error: $e');
      _showSnackBar('Failed to delete recording: ${e.toString()}');
    }
  }

  Future<void> _shareRecording(RecordingItem recording) async {
    try {
      if (kIsWeb) {
        _showSnackBar(
          'Sharing is not supported on web. Use the Download option instead.',
        );
        return;
      }

      final file = File(recording.pathOrUrl);
      if (!await file.exists()) {
        _showSnackBar('File not found');
        return;
      }

      final extension = recording.pathOrUrl.split('.').last;
      final mimeType = extension == 'm4a' ? 'audio/m4a' : 'audio/*';

      await Share.shareXFiles([
        XFile(file.path, mimeType: mimeType),
      ], text: 'Check out this recording from Voice Recorder');
    } catch (e) {
      if (kDebugMode) print('Share error: $e');
      _showSnackBar('Failed to share: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        backgroundColor: kPrimaryPink,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showRecordingDetails(RecordingItem recording) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recording.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: kPrimaryPink),
                title: const Text('Date'),
                subtitle: Text(recording.formattedDate),
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: kPrimaryPink),
                title: const Text('Duration'),
                subtitle: Text(recording.formattedDuration),
              ),
              ListTile(
                leading: recording.isCallRecording
                    ? const Icon(Icons.call, color: kAccentRed)
                    : const Icon(Icons.mic, color: kPrimaryPink),
                title: const Text('Type'),
                subtitle: Text(
                  recording.isCallRecording
                      ? 'Call Recording'
                      : 'Voice Recording',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: kPrimaryPink)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _cancelAmplitudeStream();
    if (!kIsWeb) {
      _audioRecorder.dispose();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _recorderStatus == RecorderStatus.recording;
    final isDisposing = _recorderStatus == RecorderStatus.disposing;
    final isButtonDisabled = _isLoading || isDisposing;

    return Scaffold(
      backgroundColor: kWhiteColor, // Changed from kLightGrey to WHITE
      appBar: AppBar(
        title: Text(
          _isAppointmentContext ? 'Consultation Session' : 'Walk-in Session',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryPink))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Patient Header
                  if (_isAppointmentContext)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: kWhiteColor,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient: ${widget.patientName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Type: ${widget.consultationType ?? 'N/A'} | Appt ID: ${widget.appointmentId ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Divider(height: 20, thickness: 1),
                        ],
                      ),
                    ),

                  // Recording Controls Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Session Type Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('Session Voice'),
                              selected: !_isCallRecordingMode,
                              onSelected: (_) {
                                if (isRecording) {
                                  _stopRecording();
                                }
                                setState(() {
                                  _isCallRecordingMode = false;
                                });
                              },
                              selectedColor: kPrimaryPink,
                              labelStyle: TextStyle(
                                color: !_isCallRecordingMode
                                    ? Colors.white
                                    : kDarkText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text('Session Call'),
                              selected: _isCallRecordingMode,
                              onSelected: (_) {
                                if (isRecording) {
                                  _stopRecording();
                                }
                                setState(() {
                                  _isCallRecordingMode = true;
                                });
                              },
                              selectedColor: kAccentRed,
                              labelStyle: TextStyle(
                                color: _isCallRecordingMode
                                    ? Colors.white
                                    : kDarkText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Record Button
                        GestureDetector(
                          onTap: isButtonDisabled
                              ? null
                              : (isRecording
                                    ? _stopRecording
                                    : () => _startRecording(
                                        isCallRecording: _isCallRecordingMode,
                                      )),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRecording
                                  ? (_isCallRecordingMode
                                        ? kAccentRed
                                        : kPrimaryPink)
                                  : (_isCallRecordingMode
                                        ? kAccentRed.withOpacity(0.8)
                                        : kPrimaryPink.withOpacity(0.8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording
                                  ? Icons.mic
                                  : (_isCallRecordingMode
                                        ? Icons.call
                                        : Icons.mic_none),
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          isDisposing
                              ? 'Finalizing Recording...'
                              : (isRecording
                                    ? (_isCallRecordingMode
                                          ? 'Recording Session Call...'
                                          : 'Recording Session...')
                                    : (_isCallRecordingMode
                                          ? 'Tap to Record Session Call'
                                          : 'Tap to Record Session')),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDisposing
                                ? Colors.grey
                                : (isRecording
                                      ? (_isCallRecordingMode
                                            ? kAccentRed
                                            : kPrimaryPink)
                                      : (_isCallRecordingMode
                                            ? kAccentRed
                                            : kPrimaryPink)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _formatDuration(_recordingDuration),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: kDarkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Playback Progress
                  if (_currentlyPlayingId != null &&
                      _currentPlayingDuration != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: kWhiteColor,
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: _currentPlayingDuration!.inMilliseconds > 0
                                ? _playbackPosition.inMilliseconds /
                                      _currentPlayingDuration!.inMilliseconds
                                : 0,
                            backgroundColor: Colors.grey[300],
                            color: kPrimaryPink,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_playbackPosition),
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                _formatDuration(_currentPlayingDuration!),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Playback Controls
                  if (_currentlyPlayingId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: kWhiteColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 30,
                              color: kPrimaryPink,
                            ),
                            onPressed: _isPlaying
                                ? _pausePlayback
                                : _resumePlayback,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.stop,
                              size: 30,
                              color: kAccentRed,
                            ),
                            onPressed: _stopPlayback,
                          ),
                        ],
                      ),
                    ),

                  // Recordings List Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: kWhiteColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Session Recordings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkText,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.audiotrack,
                              size: 20,
                              color: kPrimaryPink,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_recordings.length}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryPink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Recordings List
                  Container(
                    child: Container(
                      color: kLightGrey,
                      child: _recordings.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_none,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'No session recordings yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Tap the microphone button to start session recording',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap:
                                  true, // Important for nested scrolling
                              physics:
                                  const NeverScrollableScrollPhysics(), // Let parent scroll
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _recordings.length,
                              itemBuilder: (context, index) {
                                final recording = _recordings[index];
                                final isPlaying =
                                    _currentlyPlayingId == recording.id;
                                final isCurrentPlaying =
                                    isPlaying && _isPlaying;

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPlaying
                                        ? kPrimaryPink.withOpacity(0.05)
                                        : (recording.isCallRecording
                                              ? kAccentRed.withOpacity(0.05)
                                              : kWhiteColor),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isPlaying
                                            ? kPrimaryPink
                                            : (recording.isCallRecording
                                                  ? kAccentRed
                                                  : Colors.grey[200]),
                                      ),
                                      child: Icon(
                                        recording.isCallRecording
                                            ? Icons.call
                                            : Icons.audiotrack,
                                        color: isPlaying
                                            ? Colors.white
                                            : (recording.isCallRecording
                                                  ? Colors.white
                                                  : kPrimaryPink),
                                      ),
                                    ),
                                    title: Text(
                                      recording.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: recording.isCallRecording
                                            ? kAccentRed
                                            : kDarkText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recording.formattedDate,
                                          style: const TextStyle(
                                            color: kDarkText,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              recording.formattedDuration,
                                              style: const TextStyle(
                                                color: kDarkText,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            if (recording.isCallRecording)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: kAccentRed,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'CALL',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isCurrentPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: recording.isCallRecording
                                                ? kAccentRed
                                                : kPrimaryPink,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            if (isCurrentPlaying) {
                                              _pausePlayback();
                                            } else {
                                              _playRecording(recording);
                                            }
                                          },
                                        ),
                                        PopupMenuButton(
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              onTap: () =>
                                                  _showRecordingDetails(
                                                    recording,
                                                  ),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.info,
                                                    color: kPrimaryPink,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Details'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              onTap: () =>
                                                  _downloadRecording(recording),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.download,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Download to System (.m4a)',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              onTap: () =>
                                                  _shareRecording(recording),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Share'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              onTap: () =>
                                                  _deleteRecording(recording),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: kAccentRed,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: kWhiteColor,
        selectedItemColor: kPrimaryPink,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 1, // Appointments index
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateToDashboard(context);
              break;
            case 1:
              _navigateToAppointments(context);
              break;
            case 2:
              _navigateToMessages(context);
              break;
            case 3:
              _navigateToCriticalCases(context);
              break;
            case 4:
              _navigateToPatients(context);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Critical Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Patients',
          ),
        ],
      ),
    );
  }
}
