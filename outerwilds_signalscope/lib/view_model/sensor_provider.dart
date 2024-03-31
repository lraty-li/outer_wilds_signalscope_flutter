import 'package:motion_sensors/motion_sensors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'sensor_provider.g.dart';

class RotationVector {
  RotationVector(
      {required this.x,
      required this.y,
      required this.z,
      required this.cosTheta});
  double x;
  double y;
  double z;
  double cosTheta;
}

final messageProvider =
    StreamProvider.autoDispose<RotationVector>((ref) async* {
  final rotationVector = RotationVector(x: 0, y: 0, z: 0, cosTheta: 0);
  motionSensors.rotationVectorUpdateInterval =
      Duration.microsecondsPerSecond ~/ 60; //TODO changeable fps?

  await for (var event in motionSensors.rotationVector) {
    rotationVector.x = event.x;
    rotationVector.y = event.y;
    rotationVector.z = event.z;
    rotationVector.cosTheta = event.cosTheta;
    yield rotationVector;
  }
});

@riverpod
Stream<RotationVector> rotation(RotationRef ref) async* {
  final rotationVector = RotationVector(x: 0, y: 0, z: 0, cosTheta: 0);
  motionSensors.rotationVectorUpdateInterval =
      Duration.microsecondsPerSecond ~/ 60; //TODO changeable fps?

  await for (var event in motionSensors.rotationVector) {
    rotationVector.x = event.x;
    rotationVector.y = event.y;
    rotationVector.z = event.z;
    rotationVector.cosTheta = event.cosTheta;
    yield rotationVector;
  }
}
