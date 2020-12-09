import 'package:flushbar/flushbar.dart';

import '../repository/settings_repository.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  CartBottomDetailsWidget({Key key, @required CartController con})
      : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: 172,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: '0')
                    ],
                  ),
                  SizedBox(height: 1),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      if (Helper.canDelivery(_con.carts[0].food.restaurant, carts: _con.carts)) Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: 'Free') else Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: 'Free')
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Tax (${_con.carts[0].food.restaurant.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 10),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: FlatButton(
                          onPressed: () {
                            for (int i = 0; i < _con.carts.length; i++) {
                              var food = _con.carts[i].food;

                              if (food.outOfStock) {
                                Helper.showSnackbar(context, "We're sorry, one or more food items in your cart are currently sold out");
                                return;
                              }
                            }

                            if (_con.subTotal < _con.restaurant.minOrderAmount) {
                              Helper.showSnackbar(context, 'Minimum amount to place order with this restaurant is ${setting.value?.defaultCurrency}${_con.restaurant.minOrderAmount}. Your current order total is ${setting.value?.defaultCurrency}${_con.subTotal}');
                            } else {
                              _con.goCheckout(context);
                            }
                          },
                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          color: !_con.carts[0].food.restaurant.closed ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Text(
                            S.of(context).checkout,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)), zeroPlaceholder: 'Free'),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
