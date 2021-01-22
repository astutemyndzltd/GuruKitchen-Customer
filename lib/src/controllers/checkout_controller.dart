import 'dart:convert';

import 'package:GuruKitchen/src/helpers/helper.dart';
import 'package:GuruKitchen/src/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart' as stripe;
import 'package:stripe_payment/stripe_payment.dart';
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart' as guru;
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
  guru.CreditCard creditCard;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.payment = new Payment('Credit Card');
    this.listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  void addOrder(PaymentMethod paymentMethod, VoidCallback onAuthenticationFailed, VoidCallback onSuccess, VoidCallback onError, VoidCallback onRestaurantNotAvailable) async {

    var order = Order();
    order.orderType = settingRepo.orderType;
    order.note = settingRepo.orderNote ?? '';
    order.preorderInfo = settingRepo.preorderInfo;
    order.foodOrders = List<FoodOrder>();
    order.tax = carts[0].food.restaurant.defaultTax;
    order.deliveryFee = order.orderType == 'Pickup' ? 0 : carts[0].food.restaurant.deliveryFee;

    var orderStatus = new OrderStatus();
    orderStatus.id = '1';
    order.orderStatus = orderStatus;
    order.deliveryAddress = settingRepo.deliveryAddress.value;

    for (var cartItem in carts) {
      var foodOrder = new FoodOrder();
      foodOrder.quantity = cartItem.quantity;
      foodOrder.price = cartItem.food.price;
      foodOrder.food = cartItem.food;
      foodOrder.extras = cartItem.extras;
      order.foodOrders.add(foodOrder);
    }

    var overlayLoader = Helper.overlayLoader(context);
    Overlay.of(context).insert(overlayLoader);

    var restaurant = await getRestaurantDetails(carts[0].food.restaurant.id);

    bool proceed = settingRepo.preorderInfo != '' ? restaurant.isAvailableForPreorder() : restaurant.isCurrentlyOpen();

    if (proceed) {

      var response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentMethodId: paymentMethod.id, cardBrand: paymentMethod.card.brand.capitalize());

      if (response['message'] == 'requires action') {

        var clientSecret = response['data']['client_secret'].toString();

        try {
          var paymentIntent = await stripe.StripePayment.authenticatePaymentIntent(clientSecret: clientSecret);
          if (paymentIntent.status == 'succeeded') {
            response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentIntentId: paymentIntent.paymentIntentId, cardBrand: paymentMethod.card.brand.capitalize());
          }
        }
        catch(e) {
          onAuthenticationFailed?.call();
        }
      }

      if (response['message'] == 'succeeded') {
        settingRepo.coupon = Coupon.fromJSON({});
        onSuccess?.call();
      }

      if (response['message'] == 'invalid status') {
        onError?.call();
      }

    }
    else {
      onRestaurantNotAvailable?.call();
    }

    overlayLoader.remove();

  }

  void updateCreditCard(guru.CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }

}
