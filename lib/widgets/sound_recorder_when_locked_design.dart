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
    required this.shadowColor,
    required this.cancelTextBackGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: cancelTextBackGroundColor ?? Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: InkWell(
        onTap: () {
          soundRecordNotifier.isShow = false;
          soundRecordNotifier.resetEdgePadding();
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
                      overflow: TextOverflow.clip,
                      style: cancelTextStyle ??
                          const TextStyle(
                            color: Colors.black,
                          ),
                    ),
                  )),
            ),

            /// counter text
            ShowCounter(
              soundRecorderState: soundRecordNotifier,
              counterTextStyle: counterTextStyle,
              counterBackGroundColor: counterBackGroundColor,
              fullRecordPackageHeight: fullRecordPackageHeight,
            ),
          ],
        ),
      ),
    );
  }
}
