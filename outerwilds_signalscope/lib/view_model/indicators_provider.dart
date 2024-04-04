import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:outerwilds_signalscope/view_model/sensor_provider.dart';
import 'package:outerwilds_signalscope/view_model/three_demension_provider.dart';
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
    initSensor();
    return List<IndicatorData>.filled(
        planetsData.length, IndicatorData(factor: 0));
  }

  initSensor() {
    ref.listen(rotationProvider, (previous, next) {
      next.whenData((rotation) => update(rotation));
    });
  }

  var cameraDirection = Vector3();
  var tempVector3 = Vector3();

  //TODO 加速计，摄像机平移？够不够准确呢
  void update(List<double> rotation) {
    if (ref.read(threeDSceneProvider)) {
      final camera = ref.read(threeDSceneProvider.notifier).cameraPerspective;

      camera.getWorldDirection(cameraDirection);
    }

    //TODO 把摄像机朝向值抽出来，监听摄像机朝向数值而不是传感器？
    // 当前问题：widget被dispose了，数据丢失
    final planets = ref.watch(planetListProvider);
    List<IndicatorData> tempData = [];
    for (var i = 0; i < planets.length; i++) {
      var planet = planets[i];
      tempVector3.set(planet.location.x, planet.location.y, planet.location.z);
      var cosine = cameraDirection.dot(tempVector3) /
          (cameraDirection.length() * tempVector3.length());
      //在180度内
      if (cosine > 0) {
        tempData.add(IndicatorData(factor: cosine));
      }
    }
    state = tempData;
  }
}
