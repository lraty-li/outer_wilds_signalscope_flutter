import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:outerwilds_signalscope/models/planet.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:motion_sensors/motion_sensors.dart';

// [MagnetometerEvent (x: -23.6, y: 6.2, z: -34.9)]
class HomeState {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;
  late three.Scene scene;
  late three.Camera camera;
  //TODO shrink the useless code
  late three.Camera cameraPerspective;

  late three.CameraHelper activeHelper;

  late three.CameraHelper cameraPerspectiveHelper;

  late Function mySetstate;

  int frustumSize = 600;

  double dpr = 1.0;

  num aspect = 1.0;

  var amount = 4;

  bool verbose = false;
  bool disposed = false;
  late final bool mykisweb;

  late three.WebGLRenderTarget renderTarget;
  dynamic sourceTexture;
  three.Vector4 _rotationVector = three.Vector4(0, 0, 0, 0);
  double accelerometerZ = 0.0;

  //indicator
  List<Planet> planets = [];
  List<double> indicatorFactors = List.filled(11, 0);

  //https://github.com/wasabia/three_dart/blob/main/example/lib/webgl_camera.dart
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {


    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    mySetstate(() {}); // to bump a frame?

    // Wait for web  //? centain time?
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initScene() {
    initRenderer();
    initPage();
    initRotationSensor();
  }

  initRotationSensor() {
    motionSensors.rotationVectorUpdateInterval =
        Duration.microsecondsPerSecond ~/ 60; //TODO changeable fps?
    // 把轴向 “竖起来”，比较符合使用手机的直觉操作?
    //pitch检测的是地面屏幕跟屏幕屏幕的角度，无法区分相对 手机屏幕垂直地面时，是仰视还是俯视（角度值一样），配合加速计判断（要是直接得到旋转矢量可能还好）
    // motionSensors.orientation.listen((OrientationEvent event) {
    motionSensors.rotationVector.listen((RotationVectorEvent event) {
      _rotationVector.set(event.x, event.y, event.z, event.cosTheta);

      // var newPitch = event.pitch - Math.pi / 2;
      // var newYaw = event.yaw;
      // if (accelerometerZ < 0) {
      //   //https://stackoverflow.com/questions/17747823/android-sensormanager-getorientation-returns-pitch-between-pi-2-and-pi-2
      //   newPitch = -newPitch;
      //   newYaw = Math.pi + newYaw;
      // }
      //欧拉描述变换顺序问题。会产生锁
      // cameraPerspective.lookAt(three.Vector3(lookAtX, lookAtY, lookAtZ)); //改包用四元数吧还是

      cameraPerspective.setRotationFromQuaternion(
          three.Quaternion(event.x, event.y, event.z, event.cosTheta));
      // render();
    });
  }

  initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;
    renderer!.autoClear = false;

    if (!mykisweb) {
      var pars = three.WebGLRenderTargetOptions({
        "minFilter": three.LinearFilter,
        "magFilter": three.LinearFilter,
        "format": three.RGBAFormat,
        "samples": 4
      });
      renderTarget = three.WebGLRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);

      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initPage() {
    aspect = width / (height / 2);

    scene = three.Scene();
    // debug
    var axes = three.AxesHelper(50);
    scene.add(axes);
//debug end

    //

    camera = three.PerspectiveCamera(50, aspect, 1, 10000);
    camera.position.x = 100;
    camera.position.y = 0;
    camera.position.z = 0;
    camera.lookAt(three.Vector3(0, 0, 0));

    cameraPerspective = three.PerspectiveCamera(50, aspect, 150, 1000);

    cameraPerspectiveHelper = three.CameraHelper(cameraPerspective);
    scene.add(cameraPerspectiveHelper);

    activeHelper = cameraPerspectiveHelper;

    // counteract different front orientation of cameras vs rig

    // cameraPerspective.rotation.y = Math.pi;

    // cameraRig = three.Group();

    // cameraRig.add(cameraPerspective);

    // scene.add(cameraRig);

    //

    var mesh2 = three.Mesh(three.SphereGeometry(5, 16, 8),
        three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": false}));
    mesh2.position.x = 10;
    mesh2.position.z = 0;
    // scene.add(mesh2);

    var mesh3 = three.Mesh(three.SphereGeometry(5, 16, 8),
        three.MeshBasicMaterial({"color": 0x31A174, "wireframe": false}));
    mesh3.position.x = 0;
    mesh3.position.z = 10;
    // scene.add(scene);

    //

    var geometry = three.BufferGeometry();
    List<double> vertices = [];

    for (var i = 0; i < 1000; i++) {
      vertices.add(three.MathUtils.randFloatSpread(2000)); // x
      vertices.add(three.MathUtils.randFloatSpread(2000)); // y
      vertices.add(three.MathUtils.randFloatSpread(2000)); // z
    }

    geometry.setAttribute('position',
        three.Float32BufferAttribute(Float32Array.fromList(vertices), 3));

    var particles = three.Points(
        geometry, three.PointsMaterial({"color": 0x888888, "size": 5}));
    scene.add(particles);
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    renderer!.clear();

    renderer!.setViewport(0, height / 2, width, height / 2);
    renderer!.render(scene, camera);

    // 注意：实际效果该viewport在手机屏幕下半部分
    renderer!.setViewport(0, 0, width, height / 2);
    renderer!.render(scene, cameraPerspective);
    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    // var pixels = _gl.readCurrentPixels(0, 0, 10, 10);
    // print(" --------------pixels............. ");
    // print(pixels);

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }
}
