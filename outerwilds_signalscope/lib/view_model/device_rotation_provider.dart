import 'package:motion_sensors/motion_sensors.dart';
import 'package:outerwilds_signalscope/constant/universal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_rotation_provider.g.dart';

@riverpod
Stream<List<double>> deviceRotation(DeviceRotationRef ref) async* {
  motionSensors.rotationVectorUpdateInterval =
      Duration.microsecondsPerSecond ~/ fps; //TODO changeable fps?

  await for (var event in motionSensors.rotationVector) {
    yield [
      event.x,
      event.y,
      event.z,
      event.cosTheta,
    ];
  }
}
