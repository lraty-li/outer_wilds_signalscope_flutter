import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/view_model/cosine_provider.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:three_dart/three3d/math/vector3.dart';

part 'indicators_provider.g.dart';

class IndicatorData {
  IndicatorData({required this.factor});
  double factor;
  //color
}

@riverpod
class IndicatorList extends _$IndicatorList {
  @override
  List<IndicatorData> build() {
    ref.onDispose(() => print("IndicatorList dispose"));
    _initSensor();
    return List<IndicatorData>.filled(
        planetsData.length, IndicatorData(factor: 0));
  }

  _initSensor() {
    ref.listen(cosinePlanetCameraProvider, (previous, next) {
      next.whenData((cosinValues) => updateData(cosinValues));
    });
  }

  var cameraDirection = Vector3();
  var tempVector3 = Vector3();

  //TODO 加速计，摄像机平移？够不够准确呢
  void updateData(Map<int, double> cosinValues) {
    final planets = ref.watch(planetListProvider);
    List<IndicatorData> tempData = [];
    for (var i = 0; i < planets.length; i++) {
      //在180度内
      double cosine = cosinValues[planets[i].id] ?? -1;
      if (cosine > 0) {
        tempData.add(IndicatorData(factor: cosine));
      }
    }
    state = tempData;
  }
}
