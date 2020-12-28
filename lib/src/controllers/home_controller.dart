import 'package:GuruKitchen/src/models/DispatchMethod.dart';

import '../models/cuisine.dart';
import '../repository/cuisine_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {

  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Restaurant> showableRestaurants = <Restaurant>[];
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  List<Cuisine> cuisines = <Cuisine>[];
  List<Restaurant> nearbyRestaurants = <Restaurant>[];
  List<Restaurant> popularRestaurantsNearby = <Restaurant>[];

  bool listeningForNearbyRestaurants = false;
  bool listeningForPopularRestaurants = false;

  HomeController() {
    listenForNearbyRestaurants();
    listenForCuisines();
    listenForPopularRestaurants();
    listenForRecentReviews();
  }

  Future<void> listenForNearbyRestaurants() async {
    listeningForNearbyRestaurants = true;
    nearbyRestaurants = await getNearbyRestaurants();
    showableRestaurants.clear();

    for (var restaurant in nearbyRestaurants) {
      if (!restaurant.closed) {
        if (dispatchMethod == DispatchMethod.delivery && !restaurant.availableForDelivery) continue;
        //if (isPreOrderEnabled) continue;
        showableRestaurants.add(restaurant);
      }
    }

    listeningForNearbyRestaurants = false;

    if (!listeningForNearbyRestaurants && !listeningForPopularRestaurants) loadPopularRestaurants();

    setState((){});

  }

  Future<void> listenForCuisines() async {
    final Stream<Cuisine> stream = await getCuisines();

    stream.listen((Cuisine _cuisine) {
      setState(() => cuisines.add(_cuisine));
    }, onError: (e) {
      print(e);
    }, onDone: () {});
  }

  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopRestaurants() async {
    final Stream<Restaurant> stream = await getNearRestaurants(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => showableRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularRestaurants() async {
    listeningForPopularRestaurants = true;
    final Stream<Restaurant> stream = await getPopularRestaurants(deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => popularRestaurants.add(_restaurant));
    }, onError: (a) {
      listeningForPopularRestaurants = false;
    }, onDone: () {
      listeningForPopularRestaurants = false;
      if (!listeningForNearbyRestaurants && !listeningForPopularRestaurants) loadPopularRestaurants();
    });
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingFoods() async {
    final Stream<Food> stream = await getTrendingFoods(deliveryAddress.value);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> refreshHome() async {

    setState(() {
      nearbyRestaurants = <Restaurant>[];
      popularRestaurants = <Restaurant>[];
      cuisines = <Cuisine>[];
      recentReviews = <Review>[];
    });

    listenForNearbyRestaurants();
    listenForCuisines();
    listenForPopularRestaurants();
    listenForRecentReviews();

  }

  loadPopularRestaurants() {

    popularRestaurantsNearby.clear();

    var map = Map<String, Restaurant>();
    nearbyRestaurants.forEach((r) => map[r.id] = r);

    for (var p in popularRestaurants) {
      if (map[p.id] != null) {
        popularRestaurantsNearby.add(p);
      }
    }

    setState(() {});

  }
}
