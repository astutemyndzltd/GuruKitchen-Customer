import 'dart:async';

import 'package:GuruKitchen/src/models/address.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../src/repository/settings_repository.dart';
import '../../src/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LocationChoiceController extends ControllerMVC {

  Future<dynamic> pickLocationAutomatically(BuildContext context) async {

    final whenDone = new Completer();
    var loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);

    pickAndSetLocationAutomatically().then((address) async {
      deliveryAddress.value = address;
      loader.remove();
      whenDone.complete();
    }).catchError((e) {
      loader.remove();
      whenDone.complete();
    });

    return whenDone.future;
  }

  Future<Address> pickLocationManually(BuildContext bc) async {

    var locationResult = await showLocationPicker(
      bc,
      setting.value.googleMapsKey,
      initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0, deliveryAddress.value?.longitude ?? 0),
      myLocationButtonEnabled: true,
    );

    deliveryAddress.value = await setLocationManually(locationResult);

    return deliveryAddress.value;

  }
}
