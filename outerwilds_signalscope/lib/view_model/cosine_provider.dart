//the cosine(angle) of camera direction and planet

import 'package:outerwilds_signalscope/view_model/device_rotation_provider.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:three_dart/three3d/math/vector3.dart';
import 'package:three_dart/three_dart.dart' as three;
part 'cosine_provider.g.dart';

@riverpod
Stream<List<double>> cosinePlanetCamera(CosinePlanetCameraRef ref) async* {
//Only used to calculate direction
  final cameraPerspective = three.PerspectiveCamera();
  final scene = three.Scene();
  scene.add(cameraPerspective);

  var cameraDirection = Vector3();
  var tempVector3 = Vector3();
  var quaternion = three.Quaternion();

  final planets = ref.watch(planetListProvider);
  final List<double> cosineValues = [];

  final deviceRotation = ref.watch(deviceRotationProvider.future);
  var rotationVector = await deviceRotation;
  cosineValues.clear();
  quaternion.set(rotationVector[0], rotationVector[1], rotationVector[2],
      rotationVector[3]);
  cameraPerspective.setRotationFromQuaternion(quaternion);
  cameraPerspective.getWorldDirection(cameraDirection);
  for (var i = 0; i < planets.length; i++) {
    var planet = planets[i];
    tempVector3.set(planet.location.x, planet.location.y, planet.location.z);
    var cosine = cameraDirection.dot(tempVector3) /
        (cameraDirection.length() * tempVector3.length());
    cosineValues.add(cosine);
  }
  yield cosineValues;
  // final deviceRotation = ref.watch(deviceRotationProvider);
}
