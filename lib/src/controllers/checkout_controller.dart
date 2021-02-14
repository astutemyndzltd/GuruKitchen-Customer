import 'dart:convert';

import '../../src/helpers/helper.dart';
import '../../src/repository/cart_repository.dart';
import '../../src/repository/restaurant_repository.dart';
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
  final orderType = settingRepo.orderType;
  final preorderInfo = settingRepo.preorderInfo;
  bool processingOrder = false;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.payment = new Payment('Credit Card');
    this.listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  void addOrder(PaymentMethod paymentMethod, VoidCallback onAuthenticationFailed, VoidCallback onSuccess, VoidCallback onError, VoidCallback onRestaurantNotAvailable, VoidCallback onUnavailableForDelivery, VoidCallback onFoodOutOfStock) async {

    //processingOrder = true;

    var overlayLoader = Helper.overlayLoader(context);
    Overlay.of(context).insert(overlayLoader);

    var order = Order();
    order.orderType = this.orderType;
    order.note = settingRepo.orderNote ?? '';
    order.preorderInfo = this.preorderInfo;
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


    List<CartItem> cartItems = await getCartItemsNew();
    var restaurant = cartItems[0].food.restaurant;

    for (var item in cartItems) {
      if (item.food.outOfStock) {
        onFoodOutOfStock?.call();
        overlayLoader.remove();
        return;
      }
    }

    //////////////////////////////////////////////////////////////

    bool isPreOrder = this.preorderInfo != '';

    if (isPreOrder) {
      var ifForTomorrow = this.preorderInfo.contains(',');

      if (ifForTomorrow) {
        if (!restaurant.isAvailableForPreorderTomorrow()) {
          onRestaurantNotAvailable?.call();
          overlayLoader.remove();
          return;
        }
      } else {
        if (!restaurant.isAvailableForPreorderToday()) {
          onRestaurantNotAvailable?.call();
          overlayLoader.remove();
          return;
        }
      }
    } else {
      if (!restaurant.isCurrentlyOpen()) {
        onRestaurantNotAvailable?.call();
        overlayLoader.remove();
        return;
      }
    }

    ////////////////////////////////////////////////////////////

    bool isDelivery = this.orderType == 'Delivery';

    if (isDelivery) {
      if (!restaurant.availableForDelivery) {
        onUnavailableForDelivery?.call();
        overlayLoader.remove();
        return;
      }
    }

    try {
      var response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentMethodId: paymentMethod.id, cardBrand: paymentMethod.card.brand.capitalize());

      if (response['message'] == 'requires action') {
        var clientSecret = response['data']['client_secret'].toString();

        try {
          var paymentIntent = await stripe.StripePayment.authenticatePaymentIntent(clientSecret: clientSecret);
          if (paymentIntent.status == 'succeeded') {
            response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentIntentId: paymentIntent.paymentIntentId, cardBrand: paymentMethod.card.brand.capitalize());
          }
        } catch (e) {
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
    catch(e) {
      throw new Exception();
    }
    finally {
      overlayLoader.remove();
    }

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