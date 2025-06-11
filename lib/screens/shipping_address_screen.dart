import 'package:flutter/material.dart';

class ShippingAddressScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onAddNewAddress;
  final VoidCallback onApply;

  const ShippingAddressScreen({
    Key? key,
    required this.onBackPressed,
    required this.onAddNewAddress,
    required this.onApply,
  }) : super(key: key);

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  String? _selectedAddress = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        title: const Text('Shipping Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Home Address
            _buildAddressCard(
              title: 'Home',
              address: 'Addis Ababa, 4kilo',
              isSelected: _selectedAddress == 'Home',
              onSelect: () => setState(() => _selectedAddress = 'Home'),
            ),
            const SizedBox(height: 16),
            // Office Address
            _buildAddressCard(
              title: 'Office',
              address: 'Addis Ababa, Bole',
              isSelected: _selectedAddress == 'Office',
              onSelect: () => setState(() => _selectedAddress = 'Office'),
            ),
            const SizedBox(height: 20),
            // Add New Address Button
            OutlinedButton(
              onPressed: widget.onAddNewAddress,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00B686)),
                foregroundColor: const Color(0xFF00B686),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Add New Shipping Address'),
                ],
              ),
            ),
            const Spacer(),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20C997),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00B686) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<String>(
                value: title,
                groupValue: _selectedAddress,
                onChanged: (value) => onSelect(),
                activeColor: const Color(0xFF00B686),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}