/* import 'package:flutter/material.dart';
import '../core/models/clothing_model.dart';
import '../core/theme/colors.dart';
import '../core/widgets/button.dart';
import '../core/widgets/top_navigation.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({Key? key}) : super(key: key);

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final List<CartItem> _cartItems = [
    CartItem(
      clothing: ClothingItem(
        id: '1',
        title: 'Ethiopian Suit',
        price: '2000',
        imageUrl: '',
        owner: clothing,
        // other required fields...
      ),
      quantity: 2,
    ),
    CartItem(
      clothing: ClothingItem(
        id: '2',
        title: 'Habesha Kemis',
        price: '2500',
        // other required fields...
      ),
      quantity: 1,
    ),
    CartItem(
      clothing: ClothingItem(
        id: '3',
        title: 'Ethiopian Suit',
        price: '1500',
        // other required fields...
      ),
      quantity: 1,
    ),
  ];

  final double _deliveryFee = 400;

  double get _subTotal => _cartItems.fold(
    0,
        (sum, item) => sum + (double.parse(item.clothing.price) * item.quantity),
  );

  double get _totalCost => _subTotal + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Cart',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildCartItem(item);
              },
            ),
          ),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.clothing.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ETB ${item.clothing.price}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brand),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => _updateQuantity(item, -1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => _updateQuantity(item, 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalRow('Sub Total', 'ETB ${_subTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Delivery Fee', 'ETB ${_deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildTotalRow(
            'Total Cost',
            'ETB ${_totalCost.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              // Handle proceed to checkout
            },
            text: 'Proceed to Checkout',
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity > 0) {
        item.quantity = newQuantity;
      } else {
        _cartItems.remove(item);
      }
    });
  }
}

class CartItem {
  final ClothingItem clothing;
  int quantity;

  CartItem({
    required this.clothing,
    required this.quantity,
  });
}  */