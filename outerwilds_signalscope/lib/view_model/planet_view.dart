import 'package:outerwilds_signalscope/models/planet.dart';

class PlanetVm {
  PlanetVm(
      {required this.planet, this.indicatorFactor = 0, this.color = 0x4287f5});
  Planet planet;
  double indicatorFactor;
  int color;
}
