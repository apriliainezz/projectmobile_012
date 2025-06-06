import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  bool _isOptimalPosition = false;
  bool _isListening = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure plugin is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSensor();
    });
  }

  void _initializeSensor() async {
    try {
      // Wait a bit to ensure the plugin is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _startListening();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing sensor: $e';
        });
      }
    }
  }

  void _startListening() {
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen(
        (AccelerometerEvent event) {
          if (mounted) {
            setState(() {
              _x = event.x;
              _y = event.y;
              _z = event.z;
              _isListening = true;
              _errorMessage = '';
              _checkOptimalPosition();
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Sensor error: $error';
              _isListening = false;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to start sensor: $e';
          _isListening = false;
        });
      }
    }
  }

  void _checkOptimalPosition() {
    // Fix orientasi detection - landscape adalah ketika x dominan, bukan y
    // Portrait: y dominan (vertikal)
    // Landscape: x dominan (horizontal)

    // Untuk landscape optimal (90 derajat ke kiri atau kanan):
    bool isLandscape = _x.abs() > 7.0 && _y.abs() < 5.0;
    // Untuk posisi tegak lurus (tidak miring ke depan/belakang):
    bool isUpright = _z.abs() < 3.0;

    _isOptimalPosition = isLandscape && isUpright;
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Position'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: _errorMessage.isNotEmpty
            ? _buildErrorWidget()
            : _buildSensorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Sensor Not Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = '';
              });
              _initializeSensor();
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Note: Sensors may not work in emulator.\nTry on a physical device.',
            style: TextStyle(fontSize: 14, color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Temukan posisi terbaik untuk menonton drama Korea!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            _isOptimalPosition ? Icons.check_circle : Icons.warning,
            size: 100,
            color: _isOptimalPosition ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isOptimalPosition
                  ? 'Posisi Optimal untuk Menonton!'
                  : 'Ubah ke Posisi Landscape 90°',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isOptimalPosition ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Data Sensor:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _isListening ? Icons.sensors : Icons.sensors_off,
                      color: _isListening ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('X: ${_x.toStringAsFixed(2)}'),
                Text('Y: ${_y.toStringAsFixed(2)}'),
                Text('Z: ${_z.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Petunjuk: Putar perangkat ke posisi landscape dan berdiri tegak lurus',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
