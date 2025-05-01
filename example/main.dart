import 'package:flutter/material.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('asdf'),
      ),
      backgroundColor: Colors.red,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 140, left: 4, right: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SocialMediaRecorder(
                    iconsColor:Colors.red,
                    // maxRecordTimeInSecond: 5,
                    startRecording: () {
                      // function called when start recording
                    },
                    stopRecording: (time) {
                      // function called when stop recording, return the recording time
                    },
                    sendRequestFunction: (soundFile, time) {
                      //  print("the current path is ${soundFile.path}");
                    },
                    encode: AudioEncoderType.AAC,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
