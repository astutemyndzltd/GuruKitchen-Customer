import 'package:GuruKitchen/src/helpers/app_data.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';

// ignore: must_be_immutable
class DeliveryAddressesItemWidget extends StatefulWidget {

  String heroTag;
  model.Address address;
  PaymentMethod paymentMethod;
  ValueChanged<model.Address> onPressed;
  ValueChanged<model.Address> onLongPress;
  ValueChanged<model.Address> onDismissed;
  bool checkedFromStart;

  DeliveryAddressesItemWidget({Key key, this.address, this.onPressed, this.onLongPress, this.onDismissed, this.paymentMethod, this.checkedFromStart}) : super(key: key) {

  }

  @override
  _DeliveryAddressesItemWidgetState createState() => _DeliveryAddressesItemWidgetState();


}

class _DeliveryAddressesItemWidgetState extends State<DeliveryAddressesItemWidget>
{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((ts) {
        if (widget.checkedFromStart && appData.orderType == null) {
          widget.onPressed(widget.address);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onDismissed != null) {
      return Dismissible(
        key: Key(widget.address.id),
        onDismissed: (direction) {
          widget.onDismissed(widget.address);
        },
        child: buildItem(context),
      );
    } else {
      return buildItem(context);
    }
  }

  InkWell buildItem(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (!widget.checkedFromStart) {
          widget.onPressed(widget.address);
        }
      },
      onLongPress: () {
        widget.onLongPress(widget.address);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: (widget.address?.isDefault ?? false) || (widget.paymentMethod?.selected ?? false) ? Theme.of(context).accentColor : Theme.of(context).focusColor),
                  child: Icon(
                    (widget.paymentMethod?.selected ?? false) ? Icons.check : Icons.place,
                    color: Theme.of(context).primaryColor,
                    size: 38,
                  ),
                ),
              ],
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.address?.description != null
                            ? Text(
                          widget.address.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                            : SizedBox(height: 0),
                        Text(
                          widget.address?.address ?? S.of(context).unknown,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: widget.address?.description != null ? Theme.of(context).textTheme.caption : Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
