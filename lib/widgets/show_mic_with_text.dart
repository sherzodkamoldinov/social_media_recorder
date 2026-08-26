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

  /// The elapsed-time readout, laid out INSIDE the bar ahead of the label.
  ///
  /// It used to be a separate `Stack` layer painted over this widget, which
  /// clipped any "slide to cancel" translation long enough to reach under it.
  /// Passing it in as a sibling lets the row give each part its own space.
  final Widget? counter;

  /// Gradient the "slide to cancel" shimmer is painted with. `ColorizeAnimatedText`
  /// paints the glyphs with its own shader, so the colour of
  /// [slideToCancelTextStyle] is ignored — a dark theme has to override these
  /// colours here or the text stays black. Defaults to the original values.
  final List<Color>? slideToCancelColorizeColors;

  // ignore: sort_constructors_first
  const ShowMicWithText({
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
    this.counter,
    this.slideToCancelColorizeColors,
  }) : super(key: key);
  static final defaultColorizeColors = [
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
                    boxShadow: soundRecorderState.buttonPressed
                        ? [
                      BoxShadow(
                        color: shadowColor?.withValues(alpha: .5) ?? Colors.transparent,
                        blurRadius: soundRecorderState.second % 2 != 0 ? 0 : 20,
                        spreadRadius: 5,
                      )
                    ]
                        : [],
                  ),
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
              height: fullRecordPackageHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: counterBackGroundColor ?? backGroundColor ?? Colors.grey.shade100,
                // Fully rounded rather than a 12 px box: the bar sits next to a
                // circular mic button, and matching that curvature is what stops
                // the recording row from reading as stacked rectangles.
                borderRadius: BorderRadius.circular(fullRecordPackageHeight / 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (counter != null) ...[
                    counter!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: DefaultTextStyle(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            slideToCancelText ?? "",
                            textStyle: slideToCancelTextStyle ?? colorizeTextStyle,
                            colors: slideToCancelColorizeColors ?? defaultColorizeColors,
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
