library social_media_recorder;

import 'package:flutter/material.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';

/// This Class Represent Icons To swap top to lock recording
class LockRecord extends StatefulWidget {
  /// Object From Provider Notifier
  final SoundRecordNotifier soundRecorderState;

  // ignore: sort_constructors_first

  final Widget? lockIcon;

  const LockRecord({
    this.lockIcon,
    required this.soundRecorderState,
    Key? key,
  }) : super(key: key);

  @override
  State<LockRecord> createState() => _LockRecordState();
}

class _LockRecordState extends State<LockRecord> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    /// If click the Button Then send show lock and un lock icon
    if (!widget.soundRecorderState.buttonPressed) return Container();
    return Transform.translate(
      offset: const Offset(-8, -100),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
            ),
            AnimatedContainer(
              duration: Duration(seconds: 1),
              height: 15 - widget.soundRecorderState.heightPosition.clamp(0, 15),
            ),
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
