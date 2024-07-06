import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/view_model/cosine_provider.dart';
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
    print("IndicatorList build");
    ref.onDispose(() => print("IndicatorList dispose"));
    _initSensor();
    return List<IndicatorData>.filled(
        planetsData.length, IndicatorData(factor: 0));
  }

  _initSensor() {
    ref.listen(cosinePlanetCameraProvider, (previous, next) {
      next.whenData((cosinValues) => update(cosinValues));
    });
  }

  var cameraDirection = Vector3();
  var tempVector3 = Vector3();

  //TODO 加速计，摄像机平移？够不够准确呢
  void update(List<double> cosinValues) {
    List<IndicatorData> tempData = [];
    for (var i = 0; i < cosinValues.length; i++) {
      //在180度内
      double cosine = cosinValues[i];
      if (cosine > 0) {
        tempData.add(IndicatorData(factor: cosine));
      }
    }
    state = tempData;
  }
}
