import '../elements/RestaurantsWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cuisine.dart';

// ignore: must_be_immutable
class CuisinesCarouselItemWidget extends StatelessWidget {
  double marginLeft;
  Cuisine cuisine;

  CuisinesCarouselItemWidget({Key key, this.marginLeft, this.cuisine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: cuisine.name,
      child: Card(
        margin: EdgeInsets.only(right: 15),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              CachedNetworkImage(
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                imageUrl: cuisine.image.icon,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Container(
                width: 80,
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                child: Text(
                  cuisine.name,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(RestaurantOfCuisineModal(cuisine));
          },
        ),
      ),
    );
  }
}
