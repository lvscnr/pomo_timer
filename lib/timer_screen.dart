import 'dart:async';
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
  int _duration = 25; // Default timer duration in minutes
  int _currentMinutes = 25;
  int _currentSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

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

      // If the user clicks the stop button, reset the timer to 00:00
      if (!_isRunning) {
        _resetTimer();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentMinutes = 0;
      _currentSeconds = 0;
      _isRunning = false;
    });
  }

  void _updateFirestoreTimer(bool isStopped) async {
    final CollectionReference usersCollection = _firestore.collection('users');
    final DocumentReference userDoc = usersCollection
        .doc('bB7NRvX9l1ViztylqTTkXWJZ9IS2'); // Replace with user-specific ID
    if (isStopped) {
      await userDoc.collection('PomodoroTimers').doc('end_timer').set({
        'end_timer': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await userDoc.collection('PomodoroTimers').doc('timerFinished').set({
        'timerFinished': true,
      }, SetOptions(merge: true));
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
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/phase1.png'),
                  radius: 120,
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: 1 -
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
                  onPressed: () => _setDuration(1),
                  child: const Text('1 min'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _setDuration(25),
                  child: const Text('25 min'),
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
