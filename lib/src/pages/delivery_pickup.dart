import 'dart:ui';

import 'package:GuruKitchen/src/controllers/cart_controller.dart';
import 'package:GuruKitchen/src/repository/settings_repository.dart';
import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  DeliveryPickupWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {

  DeliveryPickupController _con;

  ScrollController scrollController = new ScrollController();
  int tabIndex = 0, buttonIndex = null;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
    preorderInfo = '';
  }

  @override
  Widget build(BuildContext context) {
    Slots timeSlots = _con.generateTimeSlots(15, Duration());

    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
//      widget.pickup = widget.list.pickupList.elementAt(0);
//      widget.delivery = widget.list.pickupList.elementAt(1);
    }

    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: CartBottomDetailsWidget(con: _con),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_or_pickup,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // pickup food from restaurant heading
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.domain,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).pickup,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4,
                ),
                subtitle: Text(
                  S.of(context).pickup_your_food_from_the_restaurant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
            // click to select pickup
            PickUpMethodItem(
                paymentMethod: _con.getPickUpMethod(),
                onPressed: (paymentMethod) {
                  _con.togglePickUp();
                }),
            // delivery
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.map,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).delivery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: _con.carts.isNotEmpty && Helper.canDeliver(_con.carts[0].food.restaurant, cartItems:  _con.carts)
                        ? Text(
                            S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          )
                        : Text(
                            S.of(context).deliveryMethodNotAllowed,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                  ),
                ),
                _con.carts.isNotEmpty && Helper.canDeliver(_con.carts[0].food.restaurant, cartItems: _con.carts)
                    ? DeliveryAddressesItemWidget(
                        paymentMethod: _con.getDeliveryMethod(),
                        address: _con.deliveryAddress,
                        onPressed: (Address _address) {
                          if (_con.deliveryAddress.id == null || _con.deliveryAddress.id == 'null') {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.addAddress(_address);
                              },
                            );
                          } else {
                            _con.toggleDelivery();
                          }
                        },
                        onLongPress: (Address _address) {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (Address _address) {
                              _con.updateAddress(_address);
                            },
                          );
                        },
                      )
                    : NotDeliverableAddressesItemWidget()
              ],
            ),
            // preorder
            if (_con.restaurant != null && _con.restaurant.isAvailableForPreorder())
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    // arrival time heading
                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                      padding: EdgeInsets.only(bottom: 12, top: 12, left: 20),
                      width: double.infinity,
                      child: Text(
                        'Get By',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    // now
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                      height: 45,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.timer),
                          SizedBox(width: 13),
                          Text(
                            'Now',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Expanded(child: SizedBox()),
                          Radio(
                            value: 'now',
                            groupValue: _con.radioState,
                            activeColor: Theme.of(context).accentColor,
                            focusColor: Theme.of(context).accentColor,
                            onChanged: (v) {
                              setState(() => _con.radioState = v);
                              preorderInfo = '';
                            },
                          ),
                        ],
                      ),
                    ),
                    // later
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                      height: 45,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.timer),
                          SizedBox(width: 13),
                          Text(
                            'Later',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Expanded(child: SizedBox()),
                          Radio(
                            value: 'later',
                            groupValue: _con.radioState,
                            activeColor: Theme.of(context).accentColor,
                            focusColor: Theme.of(context).accentColor,
                            onChanged: (v) {
                              setState(() => _con.radioState = v);
                              Future.delayed(Duration(milliseconds: 300), () {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                );
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    // timeslots
                    Collapsible(
                      collapsed: _con.radioState == 'now',
                      axis: CollapsibleAxis.vertical,
                      child: DefaultTabController(
                        length: timeSlots.tomorrow == null ? 1 : 2,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: [
                                Tab(
                                  child: Text(
                                    'Today',
                                    style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 17, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                if (timeSlots.tomorrow != null)
                                  Tab(
                                    child: Text(
                                      'Tomorrow',
                                      style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 17, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],

                            ),
                            Container(
                              height: 150,
                              child: TabBarView(
                                children: [
                                  // today
                                  Center(
                                    child: Container(
                                      height: 40,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return TextButton(
                                            child: Text(timeSlots.today[index]),
                                            style: TextButton.styleFrom(
                                              minimumSize: Size(140, 40),
                                              backgroundColor: (tabIndex == 0 && buttonIndex == index) ? Colors.blueAccent : Theme.of(context).accentColor,
                                              primary: Theme.of(context).primaryColor,
                                              textStyle: Theme.of(context).textTheme.headline4,
                                            ),
                                            onPressed: () {
                                              // yet to be implemented
                                              setState(() { buttonIndex = index; tabIndex = 0; });
                                              preorderInfo = timeSlots.today[index];
                                            },
                                          );
                                        },
                                        separatorBuilder: (c, i) => SizedBox(width: 15),
                                        itemCount: timeSlots.today?.length ?? 0,
                                      ),
                                    ),
                                  ),
                                  // tomorrow
                                  if (timeSlots.tomorrow != null)
                                    Center(
                                      child: Container(
                                        height: 40,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return TextButton(
                                              child: Text(timeSlots.tomorrow[index]),
                                              style: TextButton.styleFrom(
                                                minimumSize: Size(140, 40),
                                                backgroundColor: (tabIndex == 1 && buttonIndex == index) ? Colors.blueAccent : Theme.of(context).accentColor ,
                                                primary: Theme.of(context).primaryColor,
                                                textStyle: Theme.of(context).textTheme.headline4,
                                              ),
                                              onPressed: () {
                                                // yet to be implemented
                                                setState(() { buttonIndex = index; tabIndex = 1; });
                                                var tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                                preorderInfo = '${tomorrow}, ${timeSlots.tomorrow[index]}';
                                              },
                                            );
                                          },
                                          separatorBuilder: (c, i) => SizedBox(width: 15),
                                          itemCount: timeSlots.tomorrow?.length ?? 0,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
