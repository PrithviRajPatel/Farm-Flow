import 'dart:math';
import 'package:farm_flow/soil_analysis_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NpkPage extends StatefulWidget {
  const NpkPage({super.key});

  @override
  State<NpkPage> createState() => _NpkPageState();
}

class _NpkPageState extends State<NpkPage> {
  double nitrogen = 65;
  double phosphorus = 30;
  double potassium = 25;

  @override
  void initState() {
    super.initState();
    _generateRandomValues();
  }

  void _generateRandomValues() {
    final random = Random();
    setState(() {
      nitrogen = (20 + random.nextInt(61)).toDouble(); // 20-80
      phosphorus = (10 + random.nextInt(41)).toDouble(); // 10-50
      potassium = (30 + random.nextInt(71)).toDouble(); // 30-100
    });
  }

  Future<void> _showManualInputDialog() async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nController =
        TextEditingController(text: nitrogen.toString());
    final TextEditingController pController =
        TextEditingController(text: phosphorus.toString());
    final TextEditingController kController =
        TextEditingController(text: potassium.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manual NPK Input'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nitrogen (N)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: pController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Phosphorus (P)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: kController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Potassium (K)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    nitrogen = double.parse(nController.text);
                    phosphorus = double.parse(pController.text);
                    potassium = double.parse(kController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'pdf'],
    );

    if (result != null) {
      // PlatformFile file = result.files.first;
      // Here you can process the file, for now we just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully! (simulation)')),
      );
      // For demonstration, let's update NPK values randomly after "upload"
      _generateRandomValues();
    } else {
      // User canceled the picker
    }
  }

  void _fetchFromIot() {
    // Simulate fetching data from an IoT sensor by generating random values
    _generateRandomValues();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetched data from IoT sensor (simulation)')),
    );
  }

  void _navigateToAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoilAnalysisPage(
          initialN: nitrogen,
          initialP: phosphorus,
          initialK: potassium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NPK Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateRandomValues,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNpkLevelsSection(),
            const SizedBox(height: 20),
            _buildSoilTestInputSection(),
            const SizedBox(height: 20),
            _buildAiRecommendationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNpkLevelsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Soil NPK Levels",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNpkGauge("Nitrogen", nitrogen, Colors.green, 80),
                _buildNpkGauge("Phosphorus", phosphorus, Colors.orange, 50),
                _buildNpkGauge("Potassium", potassium, Colors.red, 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNpkGauge(String name, double value, Color color, double max) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value / max,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                value.toInt().toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSoilTestInputSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Soil Test Input",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInputOption(Icons.cloud_upload_outlined,
                    "Upload soil\ntest data", "CSV / PDF", _uploadFile),
                _buildInputOption(Icons.edit_outlined, "Manual input",
                    "N, P, K values", _showManualInputDialog),
                _buildInputOption(Icons.sensors_outlined, "IoT sensor",
                    "Real-time", _fetchFromIot),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputOption(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "AI Recommendation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Get a detailed analysis of your soil data and customized recommendations.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              child: const Text('Get Detailed Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
