library social_media_recorder;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// used to show mic and show dragg text when
/// press into record icon
class ShowMicWithText extends StatelessWidget {
  final bool shouldShowText;
  final String? slideToCancelText;
  final SoundRecordNotifier soundRecorderState;
  final TextStyle? slideToCancelTextStyle;
  final Color? backGroundColor;
  final Color? shadowColor;
  final Widget? recordIcon;
  final Color? counterBackGroundColor;
  final double fullRecordPackageHeight;
  final double initRecordPackageWidth;

  // ignore: sort_constructors_first
  ShowMicWithText({
    required this.backGroundColor,
    required this.shadowColor,
    required this.initRecordPackageWidth,
    required this.fullRecordPackageHeight,
    Key? key,
    required this.shouldShowText,
    required this.soundRecorderState,
    required this.slideToCancelTextStyle,
    required this.slideToCancelText,
    required this.recordIcon,
    required this.counterBackGroundColor,
  }) : super(key: key);
  final colorizeColors = [
    Colors.black,
    Colors.grey.shade200,
    Colors.black,
  ];
  final colorizeTextStyle = const TextStyle(
    fontSize: 14.0,
    fontFamily: 'Horizon',
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: !soundRecorderState.buttonPressed ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              key: soundRecorderState.key,
              scale: soundRecorderState.buttonPressed ? 1.3 : 1,
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: soundRecorderState.buttonPressed ? fullRecordPackageHeight : initRecordPackageWidth - 5,
                height: fullRecordPackageHeight,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (soundRecorderState.buttonPressed)
                          ? backGroundColor ?? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor?.withValues(alpha: .5) ?? Colors.transparent,
                          blurRadius: soundRecorderState.second % 2 != 0 ? 0 : 20,
                          spreadRadius: 5,
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: recordIcon ??
                        Icon(
                          Icons.mic,
                          size: 28,
                          color: (soundRecorderState.buttonPressed) ? Colors.grey.shade200 : Colors.black,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (shouldShowText)
          Expanded(
            child: Container(
              height: 30,
              color: backGroundColor ?? Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    child: DefaultTextStyle(
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            slideToCancelText ?? "",
                            textStyle: slideToCancelTextStyle ?? colorizeTextStyle,
                            colors: colorizeColors,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
