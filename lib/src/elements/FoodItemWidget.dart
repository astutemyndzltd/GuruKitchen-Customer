import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  const FoodItemWidget({Key key, this.food, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var foodDescription = Helper.skipHtml(food.description);

    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(id: food.id, heroTag: this.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // food image
            Hero(
              tag: heroTag + food.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  imageUrl: food.image.thumb,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 70,
                    width: 70,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // food name
                  Container(
                    width: double.infinity,
                    child: Text(
                      food.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  SizedBox(height: 3),
                  // price & rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // price
                      Row(
                        children: [
                          // price
                          Helper.getPrice(
                            food.price,
                            context,
                            style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 15),
                          ),
                          if (food.discountPrice > 0)
                            Row(
                              children: [
                                SizedBox(width: 10),
                                Helper.getPrice(
                                  food.discountPrice,
                                  context,
                                  style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 13).merge(TextStyle(decoration: TextDecoration.lineThrough)),
                                )
                              ],
                            ),
                        ],
                      ),
                      // rating
                      Row(
                        children: Helper.getStarsList(food.getRate()),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  // description
                  if(foodDescription != null && foodDescription.isNotEmpty)
                  Container(
                    width: double.infinity,
                    child: Text(
                      foodDescription,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.justify,
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
