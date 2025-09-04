import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationItem(Icons.warning, 'Low Soil Moisture', 'Your wheat field needs irrigation.', '2 hours ago'),
          _buildNotificationItem(Icons.bug_report, 'Pest Alert', 'Aphids detected in your corn field.', '1 day ago'),
          _buildNotificationItem(Icons.cloud, 'Weather Update', 'Heavy rainfall expected tomorrow.', '3 days ago'),
          _buildNotificationItem(Icons.shopping_cart, 'Mandi Price Update', 'Wheat prices have increased by 5%.', '4 days ago'),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, String title, String subtitle, String time) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        onTap: () {
          // TODO: Implement notification tap functionality
        },
      ),
    );
  }
}
