import '../elements/CuisinesCarouselWidget.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';

//import '../elements/CategoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName ?? S.of(context).home,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'slider':
                  return HomeSliderWidget(slides: _con.slides);
                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  );
                case 'top_restaurants_heading':
                  return Column(
                    children: [
                      // delivery address
                      Padding(
                        padding: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delivery Address',
                                    style: Theme.of(context).textTheme.headline4,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                    child: Text('Change', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  onTap: () {
                                    var parentScaffoldState = widget.parentScaffoldKey.currentState;

                                    var bottomSheetController = parentScaffoldState.showBottomSheet(
                                      (context) => DeliveryAddressBottomSheetWidget(
                                        scaffoldKey: widget.parentScaffoldKey,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                    );

                                    bottomSheetController.closed.then((v) => _con.refreshHome());
                                  },
                                )
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    settingsRepo.deliveryAddress.value?.address ?? '',
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.left,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      // restaurants + dispatch method
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // restaurants near you heading
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Restaurants near you',
                                    //S.of(context).top_restaurants,
                                    style: Theme.of(context).textTheme.headline4,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                            // select dispatch method - delivery/pickup/preorder
                            Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Select method',
                                      style: Theme.of(context).textTheme.bodyText1,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  // delivery button
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).focusColor.withOpacity(0.1) : Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        S.of(context).delivery,
                                        style: TextStyle(color: settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  // pickup button
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        settingsRepo.deliveryAddress.value?.address = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).focusColor.withOpacity(0.1) : Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        S.of(context).pickup,
                                        style: TextStyle(color: settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  // preorder button
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        settingsRepo.deliveryAddress.value?.address = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).focusColor.withOpacity(0.1) : Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        'Pre-Order',
                                        //S.of(context).pickup,
                                        style: TextStyle(color: settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                case 'top_restaurants':
                  return CardsCarouselWidget(restaurantsList: _con.topRestaurants, heroTag: 'home_top_restaurants');
                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                case 'trending_week':
                  return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');

                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.fastfood,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        "Cuisines",
                        //S.of(context).food_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );

                case 'categories':
                  return CuisinesCarouselWidget(
                    cuisines: _con.cuisines,
                  );

                case 'popular_heading':
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'popular':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridWidget(
                      restaurantsList: _con.popularRestaurants,
                      heroTag: 'home_restaurants',
                    ),
                  );
                case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  );
                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }
}
