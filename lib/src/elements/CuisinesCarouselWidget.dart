import 'package:flutter/material.dart';

import 'CuisinesCarouselItemWidget.dart';
import 'CircularLoadingWidget.dart';
import '../models/cuisine.dart';

// ignore: must_be_immutable
class CuisinesCarouselWidget extends StatelessWidget {
  List<Cuisine> cuisines;

  CuisinesCarouselWidget({Key key, this.cuisines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.cuisines.isEmpty
        ? CircularLoadingWidget(height: 150)
        : Container(
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListView.builder(
              itemCount: this.cuisines.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                double _marginLeft = 0;
                (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
                return new CuisinesCarouselItemWidget(
                  cuisine: this.cuisines.elementAt(index),
                );
              },
            ));
  }
}
