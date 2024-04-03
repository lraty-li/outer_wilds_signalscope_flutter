import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:outerwilds_signalscope/view_model/three_demension_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:three_dart/three3d/math/vector3.dart';

part 'indicators_provider.g.dart';

class IndicatorData {
  IndicatorData({required this.factor, required this.visiablity});
  double factor;
  bool visiablity;
}

@riverpod
class IndicatorList extends _$IndicatorList {
  @override
  List<IndicatorData> build() {
    return List<IndicatorData>.filled(
        planetsData.length, IndicatorData(factor: 0, visiablity: false));
  }

  var cameraDirection = Vector3();
  var tempVector3 = Vector3();
  void update() {
    //TODO 会更新吗
    final planets = ref.read(planetListProvider);
    final camera = ref.read(threeDSceneProvider.notifier
        .select((scene) => scene.cameraPerspective));
    camera.getWorldDirection(cameraDirection);

    for (var i = 0; i < planets.length; i++) {
      var planet = planets[i];
      tempVector3.x = planet.location.x;
      tempVector3.y = planet.location.y;
      tempVector3.z = planet.location.z;
      var cosine = cameraDirection.dot(tempVector3) /
          (cameraDirection.length() * tempVector3.length());
      //在180度内
      if (cosine > 0) {
        var positionScreenSpace = tempVector3.project(camera);
        positionScreenSpace.setZ(0);
        state[i].visiablity = true;
        state[i].factor = cosine;
      } else {
        state[i].visiablity = false;
      }
    }
  }
}
