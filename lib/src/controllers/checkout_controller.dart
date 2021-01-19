import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart' as stripe;
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment payment;
  CreditCard creditCard = new CreditCard();
  bool loading = true;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) addOrder(carts);
    super.onLoadingCartDone();
  }

  void addOrder(List<CartItem> carts) async {
    Order order = new Order();
    order.orderType = settingRepo.orderType;
    order.note = settingRepo.orderNote ?? '';
    order.preorderInfo = settingRepo.preorderInfo;
    order.foodOrders = new List<FoodOrder>();
    order.tax = carts[0].food.restaurant.defaultTax;
    order.deliveryFee = order.orderType == 'Pickup' ? 0 : carts[0].food.restaurant.deliveryFee;
    OrderStatus orderStatus = new OrderStatus();
    orderStatus.id = '1'; // TODO default order status Id
    order.orderStatus = orderStatus;
    order.deliveryAddress = settingRepo.deliveryAddress.value;

    double orderPrice = 0;

    for (var cartItem in carts) {
      var foodOrder = new FoodOrder();
      foodOrder.quantity = cartItem.quantity;
      foodOrder.price = cartItem.food.price;
      foodOrder.food = cartItem.food;
      foodOrder.extras = cartItem.extras;
      orderPrice += (foodOrder.quantity * foodOrder.price);
      order.foodOrders.add(foodOrder);
    }

    orderPrice += order.deliveryFee;
    orderPrice += orderPrice * (order.tax / 100);

    var paymentMethodId = settingRepo.paymentMethodId;

    var response = await orderRepo.addOrder(order: order, payment: this.payment, price: orderPrice, paymentMethodId: paymentMethodId);

    if (response['message'] == 'requires action') {
      var clientSecret = response['data']['client_secret'].toString();
      var paymentIntent = await stripe.StripePayment.authenticatePaymentIntent(clientSecret: clientSecret);

      if (paymentIntent.status == 'succeeded') {
        response = await orderRepo.addOrder(order: order, payment: this.payment, price: orderPrice, paymentIntentId: paymentIntent.paymentIntentId);
      }
    }

    settingRepo.coupon = Coupon.fromJSON({});

    setState(() { loading = false; });

  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }
}
