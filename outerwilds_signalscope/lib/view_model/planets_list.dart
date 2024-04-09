import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/models/location.dart';
import 'package:outerwilds_signalscope/models/planet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'planets_list.g.dart';

@riverpod
class PlanetList extends _$PlanetList {
  @override
  List<Planet> build() {
    final allPlanetsData = planetsData;
    List<Planet> planets = [];
    //TODO debug use
    // for (var i = 0; i < allPlanetsData.length; i++) {
    //DEBUG
    for (var i = 0; i < 1; i++) {
      final planetData = allPlanetsData[i];
      final angle = pi;
      final orbitalRadius = planetData.orbitalRadius;
      //DEBUG END
      planets.add(Planet(
        name: planetData.name,
        radius: planetData.radius,
        orbitalRadius: planetData.orbitalRadius,
        location: Location(
          //DEBUG
          cos(angle) * orbitalRadius * .4,
          sin(angle) * orbitalRadius * .4,
          0,
          //DEBUG END
          // planetData.location.x,
          // planetData.location.y,
          // planetData.location.z,
        ),
      ));
    }
    //make ungrowable;
    List<Planet> planetsFilled = List.generate(
        planets.length, (index) => planets[index],
        growable: false);
    return planetsFilled;
  }

  updateAllLocation(double nowTime){
    for (var i = 0; i < state.length; i++) {
      final planet = state[i];
      planet.willGoto(nowTime, planet.location);
    }
  }
}
