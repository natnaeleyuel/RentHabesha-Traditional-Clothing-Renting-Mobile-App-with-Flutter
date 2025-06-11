// orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/orders_bloc.dart';
import '../core/models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  final String userId;

  const OrdersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(orderRepository: OrderRepository())
        ..add(FetchOrders(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildOrderList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final showActive = state is OrderLoaded ? state.showActiveOrders : true;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(SwitchTab(true));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: showActive ? Colors.green : Colors.grey[200],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: showActive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(SwitchTab(false));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: !showActive ? Colors.green : Colors.grey[200],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: !showActive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrderError) {
          return Center(child: Text(state.message));
        } else if (state is OrderLoaded) {
          final orders = state.showActiveOrders
              ? state.activeOrders
              : state.completedOrders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.showActiveOrders
                        ? 'No active orders!'
                        : 'No completed orders!',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price: \$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Quantity: ${order.quantity}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}