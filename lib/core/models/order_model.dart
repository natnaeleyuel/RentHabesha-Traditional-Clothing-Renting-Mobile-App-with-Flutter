class Order {
  final String id;
  final String name;
  final double totalPrice;
  final int quantity;
  final DateTime orderDate;
  final bool isCompleted;

  Order({
    required this.id,
    required this.name,
    required this.totalPrice,
    required this.quantity,
    required this.orderDate,
    required this.isCompleted,
  });
}