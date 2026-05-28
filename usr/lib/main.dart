import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArduinoMotionApp());
}

class ArduinoMotionApp extends StatelessWidget {
  const ArduinoMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Motion Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
      },
    );
  }
}

class MotionEvent {
  final DateTime timestamp;
  final String description;

  MotionEvent(this.timestamp, this.description);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isConnected = false;
  bool _isArmed = false;
  bool _motionDetected = false;
  final List<MotionEvent> _events = [];
  Timer? _mockSensorTimer;

  @override
  void dispose() {
    _mockSensorTimer?.cancel();
    super.dispose();
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (!_isConnected) {
        _isArmed = false;
        _motionDetected = false;
        _mockSensorTimer?.cancel();
      }
    });
  }

  void _toggleSystem() {
    if (!_isConnected) return;
    
    setState(() {
      _isArmed = !_isArmed;
      if (_isArmed) {
        _events.insert(0, MotionEvent(DateTime.now(), "System Armed"));
        _startMockSensor();
      } else {
        _events.insert(0, MotionEvent(DateTime.now(), "System Disarmed"));
        _motionDetected = false;
        _mockSensorTimer?.cancel();
      }
    });
  }

  void _startMockSensor() {
    // Simulates receiving data from an Arduino via Bluetooth/Serial
    _mockSensorTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isArmed) return;
      
      // Simulate random motion detection 30% of the time
      final bool hasMotion = (DateTime.now().millisecond % 10) < 3;
      
      if (hasMotion != _motionDetected) {
        setState(() {
          _motionDetected = hasMotion;
          if (_motionDetected) {
            _events.insert(0, MotionEvent(DateTime.now(), "Motion Detected!"));
          } else {
            _events.insert(0, MotionEvent(DateTime.now(), "Area Secure"));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!_isConnected) {
      statusColor = Colors.grey;
      statusText = "Disconnected";
      statusIcon = Icons.sensors_off;
    } else if (!_isArmed) {
      statusColor = Colors.blue;
      statusText = "Disarmed";
      statusIcon = Icons.shield;
    } else if (_motionDetected) {
      statusColor = Colors.redAccent;
      statusText = "MOTION DETECTED";
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = Colors.green;
      statusText = "Area Secure";
      statusIcon = Icons.verified_user;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arduino Monitor'),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: _isConnected ? Colors.blue : Colors.grey,
            ),
            tooltip: _isConnected ? 'Disconnect' : 'Connect to Arduino',
            onPressed: _toggleConnection,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          Widget content = Column(
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, size: 80, color: statusColor),
                    const SizedBox(height: 16),
                    Text(
                      statusText,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isConnected ? _toggleSystem : null,
                      icon: Icon(_isArmed ? Icons.lock_open : Icons.lock),
                      label: Text(_isArmed ? "Disarm System" : "Arm System"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Event Log
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Event Log',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _events.isEmpty
                            ? const Center(child: Text("No events recorded yet."))
                            : ListView.builder(
                                itemCount: _events.length,
                                itemBuilder: (context, index) {
                                  final event = _events[index];
                                  final timeStr = "${event.timestamp.hour.toString().padLeft(2, '0')}:"
                                                  "${event.timestamp.minute.toString().padLeft(2, '0')}:"
                                                  "${event.timestamp.second.toString().padLeft(2, '0')}";
                                  
                                  final isAlert = event.description.contains("Detected");
                                  
                                  return ListTile(
                                    leading: Icon(
                                      isAlert ? Icons.warning : Icons.info_outline,
                                      color: isAlert ? Colors.redAccent : Colors.tealAccent,
                                    ),
                                    title: Text(
                                      event.description,
                                      style: TextStyle(
                                        color: isAlert ? Colors.redAccent : null,
                                        fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: Text(timeStr),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: content),
                  ],
                ),
              ),
            );
          }
          return content;
        },
      ),
    );
  }
}
