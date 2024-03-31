import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/models/location.dart';
import 'package:outerwilds_signalscope/models/planet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'planets_list.g.dart';

class PlanetVm {
  PlanetVm(
      {required this.planet, this.indicatorFactor = 0, this.color = 0x4287f5});
  Planet planet;
  double indicatorFactor;
  int color;
}

@riverpod
class PlanetList extends _$PlanetList {
  @override
  List<Planet> build() {
    final allPlanetsData = planetsData;
    List<Planet> planets = [];
    //TODO debug use
    for (var i = 0; i < 1; i++) {
      // for (var i = 0; i < allPlanetsData.length; i++) {
      final planetData = allPlanetsData[i];
      planets.add(Planet(
        name: planetData.name,
        radius: planetData.radius,
        orbitalRadius: planetData.orbitalRadius,
        location: Location(
          planetData.location.x,
          planetData.location.y,
          planetData.location.z,
        ),
      ));
    }
    //make ungrowable;
    List<Planet> planetsFilled = List.generate(
        planets.length, (index) => planets[index],
        growable: false);
    return planetsFilled;
  }
}
