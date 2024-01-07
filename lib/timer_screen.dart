import 'dart:async';
import 'dart:math'; // Import the dart:math library
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomo_timer/utils/color_utils.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> flowerNames = [
    'flower1',
    'flower2',
    'flower3',
    'flower4',
    'flower5'
  ];

  int _duration = 25; // Default timer duration in minutes
  int _currentMinutes = 25;
  int _currentSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  DateTime? startTime;
  String assignedFlower = ''; // Store the assigned flower name
  bool initialPhase = true; // Flag to check if it's the initial phase

  @override
  void initState() {
    super.initState();
    _currentMinutes = _duration;
  }

  Future<void> _startStopTimer() async {
    if (_isRunning) {
      _timer?.cancel();
      _updateFirestoreTimer(true);
    } else {
      startTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentMinutes > 0 || _currentSeconds > 0) {
          setState(() {
            if (_currentSeconds == 0) {
              _currentMinutes--;
              _currentSeconds = 59;
            } else {
              _currentSeconds--;
            }
          });
        } else {
          _resetTimer();
          _updateFirestoreTimer(false); // Timer finished, update Firestore
        }
      });
    }

    setState(() {
      _isRunning = !_isRunning;

      // If the user clicks the start button, assign a random flower
      if (_isRunning) {
        assignRandomFlower();
        initialPhase = false; // Update initialPhase flag
      }

      // If the user clicks the stop button, reset the timer to 00:00
      // If the user clicks the stop button, reset the timer to 00:00
      if (!_isRunning) {
        _resetTimer();
        initialPhase = true; // Reset initialPhase flag when stopping the timer
      }
    });
  }

  // Function to assign a random flower
  void assignRandomFlower() {
    final random = Random();
    final randomIndex = random.nextInt(flowerNames.length);
    assignedFlower = flowerNames[randomIndex];
    print('Assigned flower: $assignedFlower');
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentMinutes = 0;
      _currentSeconds = 0;
      _isRunning = false;
      initialPhase = true; // Reset initialPhase flag
    });
  }

  void _updateFirestoreTimer(bool isStopped) async {
    final CollectionReference usersCollection = _firestore.collection('users');
    final DocumentReference userDoc = usersCollection
        .doc('bB7NRvX9l1ViztylqTTkXWJZ9IS2'); // Replace with user-specific ID

    CollectionReference timersCollection = userDoc.collection('PomodoroTimers');

    if (isStopped) {
      await timersCollection.add({
        'start_timer': startTime,
        'end_timer': FieldValue.serverTimestamp(),
        'timer_finished': false,
        'timerDuration': _duration,
      }).then((value) {
        print('End timer added successfully with ID: ${value.id}');
      }).catchError((error) {
        print('Error adding end timer: $error');
      });
    } else {
      await timersCollection.add({
        'start_timer': startTime,
        'end_timer': FieldValue.serverTimestamp(),
        'timerFinished': true,
        'timerDuration': _duration,
        'flowerReceived': assignedFlower,
      }).then((value) {
        print('Timer finished status added successfully with ID: ${value.id}');
      }).catchError((error) {
        print('Error adding timer finished status: $error');
      });
    }
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _duration = minutes;
      _currentMinutes = minutes;
      _currentSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                // Dynamically set the background image based on the assigned flower or initial phase
                CircleAvatar(
                  backgroundImage: AssetImage(initialPhase
                      ? 'assets/images/phase1.png'
                      : 'assets/images/${assignedFlower}_phase5.png'),
                  radius: 120,
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: initialPhase
                        ? 1.0
                        : 1 - // If it's the initial phase, set the value to 1.0
                            ((_currentMinutes * 60 + _currentSeconds) /
                                (_duration * 60)),
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        hexStringToColor("0A7B79")),
                    strokeWidth: 8.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Text(
              '${_currentMinutes.toString().padLeft(2, '0')}:${_currentSeconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                ),
                Text(
                  ' $_duration min',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: _isRunning
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow),
                  onPressed: _startStopTimer,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _setDuration(25),
                  child: const Text('25 min'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _setDuration(30),
                  child: const Text('30 min'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _setDuration(45),
                  child: const Text('45 min'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _setDuration(60),
                  child: const Text('60 min'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _setDuration(90),
                  child: const Text('90 min'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _setDuration(120),
                  child: const Text('120 min'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
