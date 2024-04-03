import 'package:motion_sensors/motion_sensors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'sensor_provider.g.dart';

@riverpod
Stream<List<double>> rotation(RotationRef ref) async* {
  motionSensors.rotationVectorUpdateInterval =
      Duration.microsecondsPerSecond ~/ 45; //TODO changeable fps?

  await for (var event in motionSensors.rotationVector) {
    yield [
      event.x,
      event.y,
      event.z,
      event.cosTheta,
    ];
  }
}
