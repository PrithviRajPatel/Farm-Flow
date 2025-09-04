import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _toggleIrrigationSystem(bool value) async {
    if (_user != null) {
      await _firestore.collection('controls').doc(_user!.uid).set({
        'irrigationSystemOn': value,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _setWaterPressure(double value) async {
    if (_user != null) {
      await _firestore.collection('controls').doc(_user!.uid).set({
        'waterPressure': value,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
        backgroundColor: Colors.green,
      ),
      body: _user == null
          ? const Center(child: Text("Not logged in."))
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('controls').doc(_user!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  // Initialize with default values if no data exists
                  return _buildControls(true, 50.0);
                }

                final controlData = snapshot.data!.data() as Map<String, dynamic>;
                final irrigationOn = controlData['irrigationSystemOn'] ?? false;
                final waterPressure = (controlData['waterPressure'] ?? 50.0).toDouble();

                return _buildControls(irrigationOn, waterPressure);
              },
            ),
    );
  }

  Widget _buildControls(bool irrigationSystemOn, double waterPressure) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlCard(
            title: 'Smart Irrigation System',
            icon: Icons.water_drop,
            child: SwitchListTile(
              title: const Text('System Status'),
              value: irrigationSystemOn,
              onChanged: _toggleIrrigationSystem,
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          _buildControlCard(
            title: 'Water Pressure',
            icon: Icons.speed,
            child: Column(
              children: [
                Text('Pressure: ${waterPressure.toStringAsFixed(0)} psi', style: const TextStyle(fontSize: 18)),
                Slider(
                  value: waterPressure,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  onChanged: _setWaterPressure,
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.green),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
