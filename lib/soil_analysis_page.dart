import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SoilAnalysisPage extends StatefulWidget {
  final double? initialN;
  final double? initialP;
  final double? initialK;

  const SoilAnalysisPage({
    super.key,
    this.initialN,
    this.initialP,
    this.initialK,
  });

  @override
  State<SoilAnalysisPage> createState() => _SoilAnalysisPageState();
}

class _SoilAnalysisPageState extends State<SoilAnalysisPage> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();

  List<String>? _recommendations;

  @override
  void initState() {
    super.initState();
    if (widget.initialN != null) {
      _nitrogenController.text = widget.initialN!.toStringAsFixed(2);
    }
    if (widget.initialP != null) {
      _phosphorusController.text = widget.initialP!.toStringAsFixed(2);
    }
    if (widget.initialK != null) {
      _potassiumController.text = widget.initialK!.toStringAsFixed(2);
    }
  }

  void _analyzeSoil() {
    if (_formKey.currentState!.validate()) {
      final double ph = double.tryParse(_phController.text) ?? 7.0;
      final double n = double.tryParse(_nitrogenController.text) ?? 0.0;
      final double p = double.tryParse(_phosphorusController.text) ?? 0.0;
      final double k = double.tryParse(_potassiumController.text) ?? 0.0;

      final recs = <String>[];

      // pH Recommendations
      if (ph < 6.0) {
        recs.add('🧪 pH is too acidic ($ph). Apply lime to raise the pH. The amount depends on soil type, but a general starting point is 2-5 tons per acre.');
      } else if (ph > 7.5) {
        recs.add('🧪 pH is too alkaline ($ph). Apply elemental sulfur or use acidifying fertilizers like ammonium sulfate to lower the pH.');
      } else {
        recs.add('✅ pH level ($ph) is optimal for most crops.');
      }

      // Nitrogen (N) Recommendations
      if (n < 25) { // Assuming ppm
        recs.add('📉 Nitrogen (N) level is low ($n ppm). Apply a nitrogen-rich fertilizer like Urea or Ammonium Nitrate. A split application is often most effective.');
      } else if (n > 50) {
        recs.add('📈 Nitrogen (N) level is high ($n ppm). Avoid adding more nitrogen. Excess N can harm the environment and some crops.');
      } else {
        recs.add('✅ Nitrogen (N) level ($n ppm) is adequate.');
      }

      // Phosphorus (P) Recommendations
      if (p < 15) { // Assuming ppm
        recs.add('📉 Phosphorus (P) level is low ($p ppm). Apply a phosphate fertilizer like superphosphate or DAP (diammonium phosphate).');
      } else if (p > 30) {
        recs.add('📈 Phosphorus (P) level is high ($p ppm). No phosphorus application is needed.');
      } else {
        recs.add('✅ Phosphorus (P) level ($p ppm) is adequate.');
      }

      // Potassium (K) Recommendations
      if (k < 100) { // Assuming ppm
        recs.add('📉 Potassium (K) level is low ($k ppm). Apply a potassium fertilizer like Muriate of Potash (Potassium Chloride) or Sulphate of Potash.');
      } else if (k > 200) {
        recs.add('📈 Potassium (K) level is high ($k ppm). No potassium application is needed.');
      } else {
        recs.add('✅ Potassium (K) level ($k ppm) is adequate.');
      }

      setState(() {
        _recommendations = recs;
      });
    }
  }

  @override
  void dispose() {
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Analysis Report'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 20),
            if (_recommendations != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Enter Soil Test Results',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _phController,
                label: 'Soil pH',
                hint: 'e.g., 6.5',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _nitrogenController,
                label: 'Nitrogen (N) in ppm',
                hint: 'e.g., 30',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _phosphorusController,
                label: 'Phosphorus (P) in ppm',
                hint: 'e.g., 20',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _potassiumController,
                label: 'Potassium (K) in ppm',
                hint: 'e.g., 150',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _analyzeSoil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Analyze Soil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.lightGreen.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Soil Recommendations',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ..._recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    rec,
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
