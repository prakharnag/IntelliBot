export 'order_details.dart';
import 'package:meta/meta.dart';

const String model = "gpt-4o-mini";

@immutable
class Order {
  final String orderId;
  final String productName;
  final double price;
  final String status;
  final String deliveryDate;

  const Order({
    required this.orderId,
    required this.productName,
    required this.price,
    required this.status,
    required this.deliveryDate,
  });
}

Order getOrderDetails(String orderId) {
  // Placeholder function to retrieve order details based on the order ID
  return Order(
    orderId: orderId,
    productName: "Product X",
    price: 100.0,
    status: "Delivered",
    deliveryDate: "2024-04-10",
  );
}

String escalateToAgent(Order order, String message) {
  // Placeholder function to escalate the order to a human agent
  return "Order ${order.orderId} has been escalated to an agent with message: `$message`";
}

String refundOrder(Order order) {
  // Placeholder function to process a refund for the order
  return "Order ${order.orderId} has been refunded successfully.";
}

String replaceOrder(Order order) {
  // Placeholder function to replace the order with a new one
  return "Order ${order.orderId} has been replaced with a new order.";
}

enum Action {
  escalateToAgent,
  replaceOrder,
  refundOrder,
}

@immutable
abstract class FunctionCallBase {
  final String? rationale;
  final String? imageDescription;
  final Action action;
  final String? message;

  const FunctionCallBase({
    this.rationale,
    this.imageDescription,
    required this.action,
    this.message,
  });

  String call(String orderId) {
    Order order = getOrderDetails(orderId);
    switch (action) {
      case Action.escalateToAgent:
        return escalateToAgent(order, message!);
      case Action.replaceOrder:
        return replaceOrder(order);
      case Action.refundOrder:
        return refundOrder(order);
    }
  }
}

class EscalateToAgent extends FunctionCallBase {
  const EscalateToAgent({
    super.rationale,
    super.imageDescription,
    required String super.message,
  }) : super(
          action: Action.escalateToAgent,
        );
}

abstract class OrderActionBase extends FunctionCallBase {
  const OrderActionBase({
    super.rationale,
    super.imageDescription,
    required super.action,
  });
}

class ReplaceOrder extends OrderActionBase {
  const ReplaceOrder({
    super.rationale,
    super.imageDescription,
  }) : super(
          action: Action.replaceOrder,
        );
}

class RefundOrder extends OrderActionBase {
  const RefundOrder({
    super.rationale,
    super.imageDescription,
  }) : super(
          action: Action.refundOrder,
        );
}

