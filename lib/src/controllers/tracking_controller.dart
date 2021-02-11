import 'dart:async';
import 'dart:convert';

import 'package:GuruKitchen/src/repository/settings_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../repository/order_repository.dart';
import 'dart:io' show Platform;


class TrackingController extends ControllerMVC {

  Order order;
  List<OrderStatus> orderStatus = <OrderStatus>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  StreamSubscription onMessageSubscription, onResumeSubscription, onLaunchSubscription;

  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.setupFirebaseMessageListeners();
  }

  setupFirebaseMessageListeners() {
    onMessageSubscription = firebaseMessagingStreams.onMessageStream.listen(onReceiveFirebaseMessage);
    onResumeSubscription = firebaseMessagingStreams.onResumeStream.listen(onReceiveFirebaseMessage);
    onLaunchSubscription = firebaseMessagingStreams.onLaunchStream.listen(onReceiveFirebaseMessage);
  }

  onReceiveFirebaseMessage(Map<String, dynamic> message) {
    var orderStatusId = Platform.isIOS ? message['order_status_id'].toString() : message['data']['order_status_id'].toString();
    order.orderStatus = orderStatus.firstWhere((element) => element.id == orderStatusId);
    setState((){});
  }

  @override
  void dispose() {
    onMessageSubscription.cancel();
    onLaunchSubscription.cancel();
    onResumeSubscription.cancel();
    super.dispose();
  }

  void listenForOrder({String orderId, String message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForOrderStatus();
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus orderStatus) => this.orderStatus.add(orderStatus), onError: (a) {}, onDone: () {
      if(order.orderType == 'Pickup') orderStatus.remove(orderStatus.elementAt(3));
      setState((){});
    });
  }

  getSubTitle() {
    var orderStatusId = order.orderStatus.id;
    return SizedBox(height: 0);
  }

  List<Step> getTrackingSteps(BuildContext context) {

    List<Step> orderStatusSteps = [];

    this.orderStatus.forEach((OrderStatus orderStatus) {

      orderStatusSteps.add(
        Step(
          state: StepState.complete,
          title: Text(
            orderStatus.status,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          subtitle: order.orderStatus.id == orderStatus.id ? getSubTitle() : SizedBox(height: 0),
          content: SizedBox(
              width: double.infinity,
              child: Text(
                '${Helper.skipHtml(order.hint)}',
              )),
          isActive: (int.tryParse(order.orderStatus.id)) >= (int.tryParse(orderStatus.id)),
        ),
      );

    });

    return orderStatusSteps;
  }

  Future<void> refreshOrder() async {
    order = new Order();
    listenForOrder(message: S.of(context).tracking_refreshed_successfuly);
  }

  void doCancelOrder() {
    cancelOrder(this.order).then((value) {
      setState(() {
        this.order.active = false;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      orderStatus = [];
      listenForOrderStatus();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).orderThisorderidHasBeenCanceled(this.order.id)),
      ));
    });
  }

  bool canCancelOrder(Order order) {
    return order.active == true && order.orderStatus.id == 1;
  }

}