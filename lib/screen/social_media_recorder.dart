library social_media_recorder;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/lock_record.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';
import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';

import '../audio_encoder_type.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function return the recording sound file and the time
  final Function(File soundFile, String time) sendRequestFunction;

  /// function called when start recording
  final Function()? startRecording;

  /// function called when stop recording, return the recording time (even if time < 1)
  final Function(String time)? stopRecording;

  /// recording Icon That pressesd to start record
  final Widget? recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;
  final Color? shadowColor;
  final Color? iconsColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecoringPath;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? counterBackGroundColor;

  /// use to change the colour of the blinking mic icon shown next to the
  /// counter while recording. Defaults to red.
  final Color? counterMicColor;

  /// use to change the shimmer gradient of the "slide to cancel" text. The
  /// animated text paints with its own shader, so [slideToCancelTextStyle]
  /// cannot set its colour — pass theme colours here for dark mode.
  final List<Color>? slideToCancelColorizeColors;

  // use to change lock icon to design you need it
  final Widget? lockButton;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  // this function called when cancel record function

  // use to set max record time in second
  final int? maxRecordTimeInSecond;

  // use to change full package Height
  final double fullRecordPackageHeight;

  final double initRecordPackageWidth;

  /// Custom UI. When [recordingBarBuilder] is set, the package keeps the
  /// gestures, recording, timers and thresholds but draws nothing of its own
  /// while holding: the bar (left of the button) comes from
  /// [recordingBarBuilder], the pressed button from [recordingButtonBuilder]
  /// (falls back to [recordIcon]) and the lock hint above it from
  /// [lockBuilder]. [lockedBuilder] replaces the whole locked-mode row; call
  /// `state.finishRecording()` to send and `state.cancelRecording()` to delete.
  /// Builders get the live [SoundRecordNotifier] (`elapsedSeconds`, `levels`,
  /// `lockProgress`, `cancelProgress`, `isCancelZoneReached`). Built LTR.
  final Widget Function(BuildContext context, SoundRecordNotifier state)? recordingBarBuilder;
  final Widget Function(BuildContext context, SoundRecordNotifier state)? recordingButtonBuilder;
  final Widget Function(BuildContext context, SoundRecordNotifier state)? lockBuilder;
  final Widget Function(BuildContext context, SoundRecordNotifier state)? lockedBuilder;

  /// Width of the button while recording with [recordingButtonBuilder].
  final double recordingButtonWidth;

  /// See [SoundRecordNotifier.cancelThresholdPx] / `cancelThresholdFraction`.
  final double? cancelThresholdPx;
  final double cancelThresholdFraction;

  /// See [SoundRecordNotifier.lockThresholdPx].
  final double lockThresholdPx;

  /// See [SoundRecordNotifier.minRecordSeconds].
  final int minRecordSeconds;

  /// See [SoundRecordNotifier.onCancelZoneReached], `onLocked`, `onTooShort`.
  final VoidCallback? onCancelZoneReached;
  final VoidCallback? onLocked;
  final VoidCallback? onTooShort;

  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.recordingBarBuilder,
    this.recordingButtonBuilder,
    this.lockBuilder,
    this.lockedBuilder,
    this.recordingButtonWidth = 56,
    this.cancelThresholdPx,
    this.cancelThresholdFraction = 0.5,
    this.lockThresholdPx = 50,
    this.minRecordSeconds = 2,
    this.onCancelZoneReached,
    this.onLocked,
    this.onTooShort,
    this.sendButtonIcon,
    this.initRecordPackageWidth = 40,
    this.fullRecordPackageHeight = 50,
    this.maxRecordTimeInSecond,
    this.storeSoundRecoringPath = "",
    required this.sendRequestFunction,
    this.startRecording,
    this.stopRecording,
    this.recordIcon,
    this.lockButton,
    this.counterBackGroundColor,
    this.counterMicColor,
    this.slideToCancelColorizeColors,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.blue,
    this.recordIconWhenLockBackGroundColor = Colors.blue,
    this.backGroundColor,
    this.shadowColor,
    this.iconsColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.slideToCancelTextStyle,
    this.slideToCancelText = " Slide to Cancel >",
    this.cancelText = "Cancel",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor,
    this.radius,
    Key? key,
  }) : super(key: key);

  @override
  State<SocialMediaRecorder> createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder> {
  late SoundRecordNotifier soundRecordNotifier;

  @override
  void initState() {
    soundRecordNotifier = SoundRecordNotifier(
      maxRecordTime: widget.maxRecordTimeInSecond,
      startRecording: widget.startRecording ?? () {},
      stopRecording: widget.stopRecording ?? (String x) {},
      sendRequestFunction: widget.sendRequestFunction,
      encode: widget.encode,
    );

    soundRecordNotifier.initialStorePathRecord = widget.storeSoundRecoringPath ?? "";
    soundRecordNotifier.isShow = false;
    soundRecordNotifier.voidInitialSound();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    soundRecordNotifier.maxRecordTime = widget.maxRecordTimeInSecond;
    soundRecordNotifier.startRecording = widget.startRecording ?? () {};
    soundRecordNotifier.stopRecording = widget.stopRecording ?? (String x) {};
    soundRecordNotifier.sendRequestFunction = widget.sendRequestFunction;
    soundRecordNotifier.encode = widget.encode;
    soundRecordNotifier
      ..cancelThresholdPx = widget.cancelThresholdPx
      ..cancelThresholdFraction = widget.cancelThresholdFraction
      ..lockThresholdPx = widget.lockThresholdPx
      ..minRecordSeconds = widget.minRecordSeconds
      ..onCancelZoneReached = widget.onCancelZoneReached
      ..onLocked = widget.onLocked
      ..onTooShort = widget.onTooShort;
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => soundRecordNotifier)],
      child: Consumer<SoundRecordNotifier>(
        builder: (context, value, _) {
          return Directionality(textDirection: TextDirection.rtl, child: makeBody(value));
        },
      ),
    );
  }

  Widget makeBody(SoundRecordNotifier state) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (scrollEnd) {
            state.updateScrollValue(scrollEnd.globalPosition, context);
          },
          onHorizontalDragEnd: (x) {
            /// Send or cancel is decided here, on release — see
            /// [SoundRecordNotifier.releaseRecording].
            if (state.buttonPressed && !state.isLocked) state.releaseRecording();
          },
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: recordVoice(state),
          ),
        ),
      ],
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true && widget.lockedBuilder != null) {
      return Directionality(textDirection: TextDirection.ltr, child: widget.lockedBuilder!(context, state));
    }
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
        cancelText: widget.cancelText,
        fullRecordPackageHeight: widget.fullRecordPackageHeight,
        // cancelRecordFunction: widget.cacnelRecording ?? () {},
        sendButtonIcon: widget.sendButtonIcon,
        cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
        shadowColor: widget.shadowColor,
        cancelTextStyle: widget.cancelTextStyle,
        counterBackGroundColor: widget.counterBackGroundColor,
        counterMicColor: widget.counterMicColor,
        recordIconWhenLockBackGroundColor: widget.recordIconWhenLockBackGroundColor ?? Colors.blue,
        counterTextStyle: widget.counterTextStyle,
        recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
        sendRequestFunction: widget.sendRequestFunction,
        soundRecordNotifier: state,
        stopRecording: widget.stopRecording,
      );
    }

    return Listener(
      onPointerDown: (details) => _onPointerDown(state, details),
      onPointerUp: (details) {
        /// Fires for the same lift as `onHorizontalDragEnd` above, so it must
        /// take the same decision — sending unconditionally here would send the
        /// message the user just dragged away to cancel. Whichever fires first
        /// wins; `releaseRecording` makes the second call a no-op.
        if (!state.isLocked) state.releaseRecording();
      },
      child: widget.recordingBarBuilder != null ? _customHoldBody(state) : _defaultHoldBody(state),
    );
  }

  Future<void> _onPointerDown(SoundRecordNotifier state, PointerDownEvent details) async {
    debugPrint('onPointerDown');
    try {
      bool hasPermission = await soundRecordNotifier.checkAndRequestMicrophonePermission(context);
      if (!hasPermission) {
        debugPrint('Микрофон не разрешён');
        return;
      }
      state.setNewInitialDraggableHeight(details.position.dy);
      state.resetEdgePadding();

      soundRecordNotifier.isShow = true;
      state.record(widget.startRecording);
    } on Exception catch (e) {
      debugPrint('some errorrrr: ${e.toString()}');
    }
  }

  /// Holding with custom builders: [button | bar] in RTL (button on the right),
  /// the lock hint floating above the button. Everything moves left with the drag.
  Widget _customHoldBody(SoundRecordNotifier state) {
    final double height = widget.fullRecordPackageHeight;
    final bool pressed = state.buttonPressed && soundRecordNotifier.isShow;
    final Widget button = pressed && widget.recordingButtonBuilder != null
        ? SizedBox(
            width: widget.recordingButtonWidth,
            height: height,

            /// The pressed button may be taller than the bar — it overflows
            /// symmetrically instead of pushing the row down.
            child: OverflowBox(
              maxHeight: double.infinity,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: widget.recordingButtonBuilder!(context, state),
              ),
            ),
          )
        : SizedBox(
            width: widget.initRecordPackageWidth - 5,
            height: height,
            child: Center(child: widget.recordIcon ?? const Icon(Icons.mic)),
          );
    return SizedBox(
      width: pressed ? MediaQuery.of(context).size.width : widget.initRecordPackageWidth,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(right: state.edge),
            child: Row(
              children: [
                button,
                if (pressed) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: widget.recordingBarBuilder!(context, state),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (pressed && widget.lockBuilder != null)
            Positioned(
              right: 0,
              bottom: height + 12,
              width: widget.recordingButtonWidth,
              child: Directionality(textDirection: TextDirection.ltr, child: widget.lockBuilder!(context, state)),
            ),
        ],
      ),
    );
  }

  /// The original holding UI (mic + counter + "slide to cancel" + lock).
  Widget _defaultHoldBody(SoundRecordNotifier state) {
    return AnimatedContainer(
      duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
      width: (soundRecordNotifier.isShow) ? MediaQuery.of(context).size.width : widget.initRecordPackageWidth,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: state.edge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: soundRecordNotifier.isShow
                      ? BorderRadius.circular(12)
                      : widget.radius != null && !soundRecordNotifier.isShow
                      ? widget.radius
                      : BorderRadius.circular(0),
                ),

                /// One row, not two stacked layers: the counter is handed to
                /// [ShowMicWithText] so it takes its own space ahead of the
                /// "slide to cancel" label instead of being painted over it.
                child: Center(
                  child: ShowMicWithText(
                    initRecordPackageWidth: widget.initRecordPackageWidth,
                    counterBackGroundColor: widget.counterBackGroundColor,
                    shadowColor: widget.shadowColor,
                    backGroundColor: widget.recordIconBackGroundColor,
                    fullRecordPackageHeight: widget.fullRecordPackageHeight,
                    recordIcon: widget.recordIcon,
                    shouldShowText: soundRecordNotifier.isShow,
                    soundRecorderState: state,
                    slideToCancelTextStyle: widget.slideToCancelTextStyle,
                    slideToCancelColorizeColors: widget.slideToCancelColorizeColors,
                    slideToCancelText: widget.slideToCancelText,
                    counter: soundRecordNotifier.isShow
                        ? ShowCounter(
                            counterBackGroundColor: widget.counterBackGroundColor,
                            counterMicColor: widget.counterMicColor,
                            counterTextStyle: widget.counterTextStyle,
                            soundRecorderState: state,
                            fullRecordPackageHeight: widget.fullRecordPackageHeight,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: LockRecord(
              backGroundColor: widget.backGroundColor,
              iconsColor: widget.iconsColor,
              soundRecorderState: state,
              lockIcon: widget.lockButton,
            ),
          ),
        ],
      ),
    );
  }
}
