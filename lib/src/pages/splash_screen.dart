import 'package:GuruKitchen/src/helpers/helper.dart';
import 'package:GuruKitchen/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData()  {
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {

        try {
          if (deliveryAddress.value != null && deliveryAddress.value.isValid()) {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          } else {
            Navigator.of(context).pushReplacementNamed('/LocationChoice');
          }
          //
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE34925),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/img/logo.png',
                  width: 400,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 50),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
