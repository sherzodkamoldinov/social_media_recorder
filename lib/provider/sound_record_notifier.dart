import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';

class SoundRecordNotifier extends ChangeNotifier {
  int _localCounterForMaxRecordTime = 0;
  GlobalKey key = GlobalKey();
  int? maxRecordTime;

  /// This Timer Just For wait about 1 second until starting record
  Timer? _timer;

  /// This time for counter wait about 1 send to increase counter
  Timer? _timerCounter;

  /// X of the previous drag update, used to derive how far the finger moved
  /// since. `null` until the first update of a gesture — the very first event
  /// has nothing to compare against and must not shift the button.
  double? last;

  /// True while the button has been dragged far enough left that lifting the
  /// finger cancels the recording.
  ///
  /// Only a flag: the cancel itself happens on release, never mid-drag, so the
  /// user can still slide back and send.
  bool isCancelZoneReached = false;

  /// How far the button must travel left before a release cancels, as a
  /// fraction of the screen width. Telegram asks for roughly this much — far
  /// enough to be deliberate, close enough to reach with one thumb.
  static const double _cancelDragFraction = 0.5;

  /// Used when user enter the needed path
  String initialStorePathRecord = "";

  /// recording mp3 sound Object
  final AudioRecorder recordMp3 = AudioRecorder();

  /// recording mp3 sound to check if all permisiion passed
  bool _isAcceptedPermission = false;

  /// used to update state when user draggable to the top state
  double currentButtonHeihtPlace = 0;

  /// used to know if isLocked recording make the object true
  /// else make the object isLocked false
  bool isLocked = false;

  /// when pressed in the recording mic button convert change state to true
  /// else still false
  bool isShow = false;

  /// to show second of recording
  late int second;

  /// to show minute of recording
  late int minute;

  /// to know if pressed the button
  late bool buttonPressed;

  /// used to update space when dragg the button to left
  late double edge;
  late bool loopActive;

  /// store final path where user need store mp3 record
  late bool startRecord;

  /// store the value we draggble to the top
  late double heightPosition;

  /// store status of record if lock change to true else
  /// false
  late bool lockScreenRecord;
  late String mPath;

  /// function called when start recording
  Function()? startRecording;
  Function(File soundFile, String time) sendRequestFunction;

  /// function called when stop recording, return the recording time (even if time < 1)
  Function(String time)? stopRecording;

  late AudioEncoderType encode;

  // ignore: sort_constructors_first

  SoundRecordNotifier({
    required this.stopRecording,
    required this.sendRequestFunction,
    required this.startRecording,
    this.edge = 0.0,
    this.minute = 0,
    this.second = 0,
    this.buttonPressed = false,
    this.loopActive = false,
    this.mPath = '',
    this.startRecord = false,
    this.heightPosition = 0,
    this.lockScreenRecord = false,
    this.encode = AudioEncoderType.AAC,
    this.maxRecordTime,
  });

  /// To increase counter after 1 sencond
  ///
  /// The `await` below is the reason this method needs the guards: tapping the
  /// record button and releasing it within that second leaves this call sitting
  /// in the delay, where [resetEdgePadding] cannot cancel it — it has no timer
  /// to cancel yet. Without the guards every spammed tap left one such orphan
  /// behind; they all resumed at once on the next real recording (they only
  /// stop while `buttonPressed` is false) and incremented the counter several
  /// times per second, so the max-record-time limit fired within seconds.
  void _mapCounterGenerater() async {
    if(second == 0) {
     await Future<void>.delayed(const Duration(seconds: 1));
     /// Recording was already finished or cancelled while waiting — this chain
     /// must die instead of scheduling a timer nobody owns.
     if (!buttonPressed) return;
    }
    /// Never keep two counter chains alive: only the latest timer may run.
    _timerCounter?.cancel();
    _timerCounter = Timer(const Duration(seconds: 1), () {
      _increaseCounterWhilePressed();
      if (buttonPressed) _mapCounterGenerater();
    });
  }

  finishRecording() {
    if (buttonPressed) {
      if (second > 1 || minute > 0) {
        String path = mPath;
        String time = "$minute:$second";
        sendRequestFunction(File.fromUri(Uri(path: path)), time);
      }

      /// Reported on every release, including a tap too short to produce a file.
      /// The callback is documented to fire "even if time < 1" but used to sit
      /// inside the branch above, so a short tap left callers that put UI up on
      /// [startRecording] with no signal to take it down again.
      stopRecording?.call("$minute:$second");
    }
    resetEdgePadding();
  }

  /// Throws the recording away: [sendRequestFunction] is never called, so
  /// nothing is uploaded. Mirrors what the old inline cancel did — report the
  /// elapsed time through [stopRecording], then reset.
  void cancelRecording() {
    if (buttonPressed) {
      stopRecording?.call("$minute:$second");
    }
    resetEdgePadding();
  }

  /// The single place that decides what a finger lift means.
  ///
  /// Both `onPointerUp` on the mic button and `onHorizontalDragEnd` on the
  /// surrounding detector fire for the same lift, so the decision cannot live
  /// in either of them alone — whichever arrives first must win and the other
  /// must become a no-op. [buttonPressed] is cleared by `resetEdgePadding`, so
  /// the guard below does exactly that.
  void releaseRecording() {
    if (!buttonPressed) return;
    if (isCancelZoneReached) {
      cancelRecording();
    } else {
      finishRecording();
    }
  }

  /// used to reset all value to initial value when end the record
  resetEdgePadding() async {
    _localCounterForMaxRecordTime = 0;
    isLocked = false;
    edge = 0;

    /// Both must go back to their pristine values, otherwise the next recording
    /// starts with a stale finger position (one huge jump on the first update)
    /// and, worse, already inside the cancel zone.
    last = null;
    isCancelZoneReached = false;
    buttonPressed = false;
    second = 0;
    minute = 0;
    isShow = false;
    key = GlobalKey();
    heightPosition = 0;
    lockScreenRecord = false;
    _timer?.cancel();
    _timer = null;
    _timerCounter?.cancel();
    _timerCounter = null;
    recordMp3.stop();
    notifyListeners();
  }

  /// Maps the public [AudioEncoderType] onto the `record` encoder that is
  /// actually handed to the platform recorder.
  AudioEncoder _getRecordEncoder() {
    switch (encode) {
      case AudioEncoderType.AAC:
        return AudioEncoder.aacLc;
      case AudioEncoderType.AAC_LD:
        return AudioEncoder.aacEld;
      case AudioEncoderType.AAC_HE:
        return AudioEncoder.aacHe;
      case AudioEncoderType.AMR_NB:
        return AudioEncoder.amrNb;
      case AudioEncoderType.AMR_WB:
        return AudioEncoder.amrWb;
      case AudioEncoderType.OPUS:
        return AudioEncoder.opus;
      case AudioEncoderType.WAV:
        return AudioEncoder.wav;
    }
  }

  String _getSoundExtension() {
    switch (encode) {
      case AudioEncoderType.AAC:
      case AudioEncoderType.AAC_LD:
      case AudioEncoderType.AAC_HE:
        return ".m4a";

      /// Opus lands in different containers per platform:
      /// OGG on Android, CAF on iOS — the extension has to follow.
      case AudioEncoderType.OPUS:
        return Platform.isIOS ? ".caf" : ".opus";
      case AudioEncoderType.WAV:
        return ".wav";
      case AudioEncoderType.AMR_NB:
      case AudioEncoderType.AMR_WB:
        return ".3gp";
    }
  }

  /// used to get the current store path
  Future<String> getFilePath() async {
    String sdPath = "";
    Directory tempDir = await getApplicationDocumentsDirectory();
    sdPath = initialStorePathRecord.isEmpty ? tempDir.path : initialStorePathRecord;
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime now = DateTime.now();
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    // print("the current data is $convertedDateTime");
    String storagePath = "$sdPath/$convertedDateTime${_getSoundExtension()}";
    mPath = storagePath;
    return storagePath;
  }

  /// used to change the draggable to top value
  setNewInitialDraggableHeight(double newValue) {
    currentButtonHeihtPlace = newValue;
  }

  /// used to change the draggable to top value
  /// or To The X vertical
  /// and update this value in screen
  updateScrollValue(Offset currentValue, BuildContext context) async {
    if (buttonPressed == true) {
      final x = currentValue;

      /// take the diffrent between the origin and the current
      /// draggable to the top place
      double hightValue = currentButtonHeihtPlace - x.dy;

      /// if reached to the max draggable value in the top
      if (hightValue >= 50) {
        isLocked = true;
        lockScreenRecord = true;
        hightValue = 50;
        notifyListeners();
      }
      if (hightValue < 0) hightValue = 0;
      heightPosition = hightValue;
      lockScreenRecord = isLocked;
      notifyListeners();

      /// this operation for update X oriantation
      /// draggable to the left or right place

      /// The button follows the finger one to one.
      ///
      /// It used to move by `x.dx / 200` — a fraction of the finger's ABSOLUTE
      /// screen coordinate rather than of how far it had actually moved. With a
      /// finger near the right edge of a 1080 px screen that is ~5 px of travel
      /// per update, whether or not the finger moved at all, and drag updates
      /// arrive ~60 times a second. The button therefore raced off to the left
      /// on the faintest touch and the cancel threshold was crossed instantly.
      final double previous = last ?? x.dx;
      edge += previous - x.dx;
      if (edge < 0) edge = 0;
      last = x.dx;

      /// Reaching the zone is only recorded here, never acted upon: cancelling
      /// used to happen right in this handler, which killed the recording while
      /// the finger was still down and left no way back. The decision belongs
      /// to the release — see [releaseRecording].
      isCancelZoneReached = edge >= MediaQuery.of(context).size.width * _cancelDragFraction;

      notifyListeners();
    }
  }

  /// this function to manage counter value
  /// when reached to 60 sec
  /// reset the sec and increase the min by 1
  _increaseCounterWhilePressed() async {
    if (loopActive) {
      return;
    }

    loopActive = true;
    if (maxRecordTime != null) {
      if (_localCounterForMaxRecordTime >= maxRecordTime!) {
        loopActive = false;
        finishRecording();
      }
      _localCounterForMaxRecordTime++;
    }
    second = second + 1;
    buttonPressed = buttonPressed;
    if (second == 60) {
      second = 0;
      minute = minute + 1;
    }

    notifyListeners();
    loopActive = false;
    notifyListeners();
  }

  /// this function to start record voice
  record(Function()? startRecord) async {
    /// A recording is already running — a second press (button spam, or a
    /// stray pointer event) must not start a parallel one: it would overwrite
    /// the pending timers and leave the previous recorder instance running.
    if (buttonPressed) return;

    if (!_isAcceptedPermission) {
      await Permission.microphone.request();
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      _isAcceptedPermission = true;
    } else {
      buttonPressed = true;
      String recordFilePath = await getFilePath();

      /// Drop whatever the previous (possibly aborted) recording left behind.
      _timer?.cancel();
      _timerCounter?.cancel();

      _timer = Timer(const Duration(milliseconds: 900), () {
        recordMp3.start(
          RecordConfig(
            encoder: _getRecordEncoder(),

            /// Voice messages are speech only, and the phone mic is mono
            /// anyway — 16 kHz mono is what every ASR engine resamples to.
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: recordFilePath,
        );
      });

      if (startRecord != null) {
        startRecord();
      }

      _mapCounterGenerater();
      notifyListeners();
    }
    notifyListeners();
  }

  /// to check permission
  Future<void> voidInitialSound() async {
    startRecord = false;

    final micStatus = await Permission.microphone.status;

    if (!micStatus.isGranted) {
      _isAcceptedPermission = false;
      return;
    }

    final storageStatus = await Permission.storage.status;
    final storageGranted = storageStatus.isGranted ||
        await Permission.storage.request().then((value) => value.isGranted);

    if (!storageGranted) {
      _isAcceptedPermission = false;
      return;
    }

    _isAcceptedPermission = true;
  }

  Future<bool> checkAndRequestMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;

    // Запрашиваем разрешение
    if (status.isGranted) {
      _isAcceptedPermission = true;
      return true;
    }

    if (status.isPermanentlyDenied || status.isDenied) {
      status = await Permission.microphone.request();
    }
    debugPrint('checkAndRequestMicrophonePermission: $status');

    if (status.isPermanentlyDenied) {
      // Разрешение отклонено навсегда, открываем настройки
      if (context.mounted) {
        await showPermissionDialog(context);
      }
      return false;
    }

    return false;
  }

  Future<void> showPermissionDialog(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Разрешение на микрофон'),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(), // просто закрыть
            child: const Text('Отмена'),
          ),

          CupertinoButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings(); // открываем настройки
            },
            child: const Text('Открыть\nнастройки'),
          ),
        ],
        content: const Text(
          'Для записи голосовых сообщений необходимо разрешение на использование микрофона. Пожалуйста, разрешите доступ в настройках приложения.',
        ),
      ),
    );
  }
}
