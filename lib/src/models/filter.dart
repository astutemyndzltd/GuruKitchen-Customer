import 'package:GuruKitchen/src/models/category.dart';

import '../helpers/custom_trace.dart';
import '../models/cuisine.dart';

class Filter {
  //bool delivery;
  //bool open;
  List<Cuisine> cuisines;
  List<Category> foodCategories;

  Filter();

  Filter.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      //open = jsonMap['open'] ?? false;
      //delivery = jsonMap['delivery'] ?? false;
      cuisines = jsonMap['cuisines'] != null && (jsonMap['cuisines'] as List).length > 0
          ? List.from(jsonMap['cuisines']).map((element) => Cuisine.fromJSON(element)).toList()
          : [];
      foodCategories = jsonMap['food_categories'] != null && (jsonMap['food_categories'] as List).length > 0
          ? List.from(jsonMap['food_categories']).map((element) => Category.fromJSON(element)).toList()
          : [];
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['cuisines'] = cuisines.map((element) => element.toMap()).toList();
    map['food_categories'] = foodCategories.map((element) => element.toMap()).toList();
    return map;
  }

  @override
  String toString() {
    String filter = "";
    /*if (delivery) {
      if (open) {
        filter = "search=available_for_delivery:1;closed:0&searchFields=available_for_delivery:=;closed:=&searchJoin=and";
      } else {
        filter = "search=available_for_delivery:1&searchFields=available_for_delivery:=";
      }
    } else if (open) {
      filter = "search=closed:${open ? 0 : 1}&searchFields=closed:=";
    }*/
    return filter;
  }

  Map<String, dynamic> toQuery({Map<String, dynamic> oldQuery}) {
    Map<String, dynamic> query = {};

    if (cuisines != null && cuisines.isNotEmpty) {
      query['cuisines[]'] = cuisines.map((element) => element.id).toList();
    }

    if(foodCategories != null && foodCategories.isNotEmpty) {
      query['categories[]'] = foodCategories.map((element) => element.id).toList();
    }

    return query;

  }
}
