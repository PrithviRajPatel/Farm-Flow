import 'package:flutter/material.dart';

class SeasonalRecommendationsPage extends StatelessWidget {
  const SeasonalRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seasonal Recommendations'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSeasonCard(
              season: 'Kharif (Monsoon)',
              crops: ['Rice', 'Corn', 'Soybean'],
              recommendations: [
                'Ensure good drainage in the fields to prevent waterlogging.',
                'Monitor for pests like stem borer and leaf folder.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSeasonCard(
              season: 'Rabi (Winter)',
              crops: ['Wheat', 'Barley', 'Mustard'],
              recommendations: [
                'Irrigate the crops at critical stages like tillering and grain filling.',
                'Protect the crops from frost by using sprinklers or windbreaks.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSeasonCard(
              season: 'Zaid (Summer)',
              crops: ['Cucumber', 'Watermelon', 'Moong Dal'],
              recommendations: [
                'Ensure frequent irrigation due to high temperatures.',
                'Use mulch to conserve soil moisture.',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonCard(
      {required String season, required List<String> crops, required List<String> recommendations}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(season, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Recommended Crops: ${crops.join(', ')}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('• $rec', style: const TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }
}
