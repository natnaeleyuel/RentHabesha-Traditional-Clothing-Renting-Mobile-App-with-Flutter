import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // State for dashboard statistics
  final Map<String, int> _stats = {
    'Total Users': 24,
    'Total Orders': 33,
    'Pending': 21,
    'Total Clothing': 30,
    'Completed': 12,
  };

  // Recent orders data
  final List<Map<String, String>> _recentOrders = [
    {
      'customer': 'John Abebe',
      'product': 'Ethiopian Suit',
      'status': 'Pending',
      'time': '2h ago',
      'amount': 'ETB 1,200',
    },
    {
      'customer': 'Sara Tekle',
      'product': 'Habesha Kemis',
      'status': 'Completed',
      'time': '4h ago',
      'amount': 'ETB 1,500',
    },
    {
      'customer': 'Meskerem Alemu',
      'product': 'Natala',
      'status': 'Pending',
      'time': '1h ago',
      'amount': 'ETB 800',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard('Total Users', _stats['Total Users']!, Colors.blue),
                  const SizedBox(width: 16),
                  _buildStatCard('Total Orders', _stats['Total Orders']!, Colors.green),
                  const SizedBox(width: 16),
                  _buildStatCard('Pending', _stats['Pending']!, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard('Total Clothing', _stats['Total Clothing']!, Colors.purple),
                  const SizedBox(width: 16),
                  _buildStatCard('Completed', _stats['Completed']!, Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recent Orders Section
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _recentOrders.map((order) => _buildOrderCard(order)).toList(),
            ),
            const SizedBox(height: 16),
            // View All Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to all orders screen
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['customer']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(order['product']!),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order['status'] == 'Completed'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status']!,
                    style: TextStyle(
                      color: order['status'] == 'Completed'
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
                Text(
                  order['time']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order['amount']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}