library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// The elapsed-time readout with its blinking mic.
///
/// Sized to its content and painted without a background of its own: it is laid
/// out inside the recording bar in [ShowMicWithText], which supplies the fill.
/// It used to be a fixed `width * 0.35` slab drawn in a `Stack` ON TOP of the
/// "slide to cancel" label — short labels ("Slide to cancel") peeked out to the
/// right of it and looked fine, but longer translations ("Bekor qilish uchun
/// suring") started underneath the slab and were clipped.
class ShowCounter extends StatelessWidget {
  final SoundRecordNotifier soundRecorderState;
  final TextStyle? counterTextStyle;
  final Color? counterBackGroundColor;
  final double fullRecordPackageHeight;

  /// Colour of the blinking mic icon next to the counter. Defaults to red,
  /// which is unreadable on some themes — pass a theme colour instead.
  final Color? counterMicColor;
  // ignore: sort_constructors_first
  const ShowCounter({
    required this.soundRecorderState,
    required this.fullRecordPackageHeight,
    Key? key,
    this.counterTextStyle,
    this.counterMicColor,
    required this.counterBackGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        counterTextStyle ?? const TextStyle(color: Colors.black);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: soundRecorderState.second % 2 == 0 ? 1 : 0,
          child: Icon(
            Icons.mic,
            size: 20,
            color: counterMicColor ?? Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          soundRecorderState.minute.toString().padLeft(2, '0'),
          style: style,
        ),
        Text(':', style: style),
        Text(
          soundRecorderState.second.toString().padLeft(2, '0'),
          style: style,
        ),
      ],
    );
  }
}
