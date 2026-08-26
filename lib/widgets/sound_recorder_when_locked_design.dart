library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';

// ignore: must_be_immutable
class SoundRecorderWhenLockedDesign extends StatelessWidget {
  final double fullRecordPackageHeight;
  final SoundRecordNotifier soundRecordNotifier;
  final String? cancelText;
  final Function sendRequestFunction;
  final Function(String time)? stopRecording;
  final Widget? recordIconWhenLockedRecord;
  final TextStyle? cancelTextStyle;
  final TextStyle? counterTextStyle;
  final Color recordIconWhenLockBackGroundColor;
  final Color? counterBackGroundColor;
  final Color? counterMicColor;
  final Color? cancelTextBackGroundColor;
  final Color? shadowColor;
  final Widget? sendButtonIcon;

  // ignore: sort_constructors_first
  const SoundRecorderWhenLockedDesign({
    Key? key,
    required this.fullRecordPackageHeight,
    required this.sendButtonIcon,
    required this.soundRecordNotifier,
    required this.cancelText,
    required this.sendRequestFunction,
    this.stopRecording,
    required this.recordIconWhenLockedRecord,
    required this.cancelTextStyle,
    required this.counterTextStyle,
    required this.recordIconWhenLockBackGroundColor,
    required this.counterBackGroundColor,
    this.counterMicColor,
    required this.shadowColor,
    required this.cancelTextBackGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          /// Goes through cancelRecording rather than resetEdgePadding: the
          /// latter tears the state down silently, so callers that put UI up on
          /// [SocialMediaRecorder.startRecording] never heard that the
          /// recording had ended and were left stuck.
          soundRecordNotifier.cancelRecording();
        },
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                soundRecordNotifier.isShow = false;
                soundRecordNotifier.finishRecording();
              },
              child: Transform.scale(
                scale: 1.3,
                child: AnimatedContainer(
                  width: fullRecordPackageHeight,
                  height: fullRecordPackageHeight,
                  duration: Duration(seconds: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: recordIconWhenLockBackGroundColor,
                    boxShadow: soundRecordNotifier.buttonPressed
                        ? [
                      BoxShadow(
                        color: shadowColor?.withValues(alpha: .5) ?? Colors.transparent,
                        blurRadius: soundRecordNotifier.second % 2 != 0 ? 20 : 0,
                        spreadRadius: 5,
                      ),
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: recordIconWhenLockedRecord ??
                          sendButtonIcon ??
                          Icon(
                            Icons.send,
                            textDirection: TextDirection.ltr,
                            color: (soundRecordNotifier.buttonPressed) ? Colors.grey.shade200 : Colors.black,
                          ),
                    ),
                  ),
                ),
              ),
            ),

            /// Wide enough to clear the send button's 1.3x scale — `Transform`
            /// paints outside the box without claiming the space, so a tighter
            /// gap lets the circle overlap the bar.
            const SizedBox(width: 12),

            /// The bar itself. Same pill as the unlocked state — one fill, fully
            /// rounded — instead of the old slab that was square down its left
            /// edge and butted straight into the round send button.
            Expanded(
              child: Container(
                height: fullRecordPackageHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cancelTextBackGroundColor ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(fullRecordPackageHeight / 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// counter text
                    ShowCounter(
                      soundRecorderState: soundRecordNotifier,
                      counterTextStyle: counterTextStyle,
                      counterBackGroundColor: counterBackGroundColor,
                      counterMicColor: counterMicColor,
                      fullRecordPackageHeight: fullRecordPackageHeight,
                    ),

                    /// cancel text
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          soundRecordNotifier.isShow = false;
                          String time = "${soundRecordNotifier.minute}:${soundRecordNotifier.second}";
                          if (stopRecording != null) stopRecording!(time);
                          soundRecordNotifier.resetEdgePadding();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            cancelText ?? "",
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: cancelTextStyle ??
                                const TextStyle(
                                  color: Colors.black,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
