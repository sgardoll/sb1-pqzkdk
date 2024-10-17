import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StoryVisualizerPage(),
    );
  }
}

class StoryVisualizerPage extends StatefulWidget {
  const StoryVisualizerPage({Key? key}) : super(key: key);

  @override
  _StoryVisualizerPageState createState() => _StoryVisualizerPageState();
}

class _StoryVisualizerPageState extends State<StoryVisualizerPage> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  double _decibels = 0;
  Color _backgroundColor = Colors.black;
  double _circleSize = 100;
  double _circleX = 0;
  double _circleY = 0;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        _noiseSubscription = _noiseMeter?.noiseStream.listen(_onData);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (err) {
      print(err);
    }
  }

  void _stopRecording() {
    _noiseSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  void _onData(NoiseReading noiseReading) {
    setState(() {
      _decibels = noiseReading.meanDecibel;
      _updateVisualization();
    });
  }

  void _updateVisualization() {
    // Update background color based on volume
    double hue = (_decibels * 2) % 360;
    _backgroundColor = HSLColor.fromAHSL(1, hue, 1, 0.5).toColor();

    // Update circle size based on volume
    _circleSize = 100 + (_decibels * 5);

    // Move circle randomly
    Random random = Random();
    _circleX += random.nextDouble() * 10 - 5;
    _circleY += random.nextDouble() * 10 - 5;

    // Keep circle within bounds
    _circleX = _circleX.clamp(0, MediaQuery.of(context).size.width - _circleSize);
    _circleY = _circleY.clamp(0, MediaQuery.of(context).size.height - _circleSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _isRecording ? _stopRecording : _startRecording,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _backgroundColor,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _circleX,
                top: _circleY,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Center(
                child: Text(
                  _isRecording ? 'Tap to Stop' : 'Tap to Start',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}