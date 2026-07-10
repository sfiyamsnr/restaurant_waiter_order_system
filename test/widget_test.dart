import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_waiter_order_system/models/order_item.dart';
import 'package:restaurant_waiter_order_system/models/order_status.dart';

void main() {
  test('OrderItem.subtotal multiplies price by quantity', () {
    const item = OrderItem(
      id: 'item1',
      orderId: 'order1',
      menuItemId: 'menu1',
      nameSnapshot: 'Burger',
      priceSnapshot: 9.5,
      quantity: 3,
    );
    expect(item.subtotal, 28.5);
  });

  test('OrderStatusX.fromLabel parses known labels and defaults to pending', () {
    expect(OrderStatusX.fromLabel('Preparing'), OrderStatus.preparing);
    expect(OrderStatusX.fromLabel('Paid'), OrderStatus.paid);
    expect(OrderStatusX.fromLabel('unknown'), OrderStatus.pending);
    expect(OrderStatusX.fromLabel(null), OrderStatus.pending);
  });
}
