import 'dart:convert';

import 'package:GuruKitchen/src/models/category.dart';
import 'package:GuruKitchen/src/repository/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/cuisine.dart';
import '../models/filter.dart';
import '../repository/cuisine_repository.dart';

class FilterController extends ControllerMVC {

  GlobalKey<ScaffoldState> scaffoldKey;
  List<Cuisine> cuisines = [];
  List<Category> foodCategories = [];
  Filter filter;
  Cart cart;

  FilterController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFilter().whenComplete(() {
      listenForCuisines();
      listenForFoodCategories();
    });
  }

  Future<void> listenForFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
    });
  }

  Future<void> saveFilter() async {
    var prefs = await SharedPreferences.getInstance();
    filter.cuisines = this.cuisines.where((c) => c.selected).toList();
    filter.foodCategories = this.foodCategories.where((fc) => fc.selected).toList();
    prefs.setString('filter', json.encode(filter.toMap()));
  }

  void listenForCuisines({String message}) async {
    cuisines.add(new Cuisine.fromJSON({'id': '0', 'name': S.of(context).all, 'selected': true}));
    final Stream<Cuisine> stream = await getCuisines();
    stream.listen((Cuisine cuisine) {
      setState(() {
        if (filter.cuisines.contains(cuisine)) {
          cuisine.selected = true;
          cuisines.elementAt(0).selected = false;
        }
        cuisines.add(cuisine);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFoodCategories() async {
    foodCategories.add(Category.fromJSON({'id': '0', 'name': 'All', 'selected': true}));
    var streamOfCategories = await getCategories();
    
    streamOfCategories.listen((Category category) =>foodCategories.add(category),
      onDone: () {
        for(var fc in foodCategories) {
          fc.selected = filter.foodCategories.firstWhere((cat) => cat.id == fc.id, orElse: () => null) != null;
          fc.selected && (foodCategories[0].selected = false);
          setState((){});
        }
      }
    );
  }

  Future<void> refreshCuisinesPlusCategories() async {
    cuisines.clear();
    foodCategories.clear();
    listenForCuisines();
    listenForFoodCategories();
  }

  void clearFilter() {
    setState(() {resetCuisines(); resetFoodCategories(); });
  }

  void resetCuisines() {
    filter.cuisines = [];
    cuisines.forEach((Cuisine _f) {
      _f.selected = false;
    });
    cuisines.elementAt(0).selected = true;
  }

  void resetFoodCategories() {
    filter.foodCategories = [];
    foodCategories.forEach((fc) => fc.selected = false);
    foodCategories[0].selected = true;
  }

  void onChangeCuisinesFilter(int index) {
    if (index == 0) {
      // all
      setState(() {
        resetCuisines();
      });
    } else {
      setState(() {
        cuisines.elementAt(index).selected = !cuisines.elementAt(index).selected;
        cuisines.elementAt(0).selected = false;
      });
    }
  }

  void onChangeFoodCategoriesFilter(int index) {
    if (index == 0) {
      // all
      setState(() {
        resetFoodCategories();
      });
    } else {
      setState(() {
        foodCategories.elementAt(index).selected = !foodCategories.elementAt(index).selected;
        foodCategories.elementAt(0).selected = false;
      });
    }
  }

}
