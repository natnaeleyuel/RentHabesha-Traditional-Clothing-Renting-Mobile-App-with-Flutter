// order_event.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/order_model.dart';

abstract class OrderEvent {}

class FetchOrders extends OrderEvent {
  final String userId;

  FetchOrders(this.userId);
}

class SwitchTab extends OrderEvent {
  final bool showActiveOrders;

  SwitchTab(this.showActiveOrders);
}

abstract class OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> activeOrders;
  final List<Order> completedOrders;
  final bool showActiveOrders;

  OrderLoaded({
    required this.activeOrders,
    required this.completedOrders,
    required this.showActiveOrders,
  });
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderLoading()) {
    on<FetchOrders>(_onFetchOrders);
    on<SwitchTab>(_onSwitchTab);
  }

  Future<void> _onFetchOrders(FetchOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getUserOrders(event.userId);
      final activeOrders = orders.where((o) => !o.isCompleted).toList();
      final completedOrders = orders.where((o) => o.isCompleted).toList();

      emit(OrderLoaded(
        activeOrders: activeOrders,
        completedOrders: completedOrders,
        showActiveOrders: true,
      ));
    } catch (e) {
      emit(OrderError('Failed to load orders'));
    }
  }

  void _onSwitchTab(SwitchTab event, Emitter<OrderState> emit) {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoaded(
        activeOrders: currentState.activeOrders,
        completedOrders: currentState.completedOrders,
        showActiveOrders: event.showActiveOrders,
      ));
    }
  }
}

class OrderRepository {
  Future<List<Order>> getUserOrders(String userId) async {
    return [
      Order(
        id: '1',
        name: 'Ethiopian Suit',
        totalPrice: 120.0,
        quantity: 2,
        orderDate: DateTime.now(),
        isCompleted: false,
      ),
      Order(
        id: '2',
        name: 'Hobesho Kemis',
        totalPrice: 150.0,
        quantity: 1,
        orderDate: DateTime.now(),
        isCompleted: false,
      ),
    ];
  }
}