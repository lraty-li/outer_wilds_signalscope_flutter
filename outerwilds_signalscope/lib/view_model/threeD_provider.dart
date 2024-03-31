import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/models/location.dart';
import 'package:outerwilds_signalscope/models/planet.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:outerwilds_signalscope/view_model/sensor_provider.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:three_dart/three3d/three.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:motion_sensors/motion_sensors.dart';
part 'threeD_provider.g.dart';
// [MagnetometerEvent (x: -23.6, y: 6.2, z: -34.9)]


@riverpod
class ThreeDScene extends _$ThreeDScene {
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

  int frustumSize = 600;

  double dpr = 1.0;

  num aspect = 1.0;

  var amount = 4;

  bool verbose = false;
  bool disposed = false;

  late three.WebGLRenderTarget renderTarget;
  dynamic sourceTexture;
  three.Vector4 _rotationVector = three.Vector4(0, 0, 0, 0);
  double accelerometerZ = 0.0;

  int timeStart = 0;
  int timeEnd = 1;

  // Planet , indicatorFactor
  List<PlanetVm> planets = [];

  bool renderInitialized = false;

  late Function mySetstate;

  @override
  ThreeDScene build() {
    return ThreeDScene();
  }

  //https://github.com/wasabia/three_dart/blob/main/example/lib/webgl_camera.dart
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(Size size, double devicePixelRatio, Function setState) async {
    width = size.width;
    height = size.height;
    dpr = devicePixelRatio;
    mySetstate = setState;
    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    // renderInitialized = false;// can't make it
    mySetstate(() {}); // to bump a frame?

    // Wait for web  //? centain time?
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initScene() {
    initPlanet();
    initRenderer();
    initPage();
    initRotationSensor();
  }

  initPlanet() {
    planets.clear();
    final allPlanetsData = planetsData;
    //TODO debug use
    for (var i = 0; i < 1; i++) {
      // for (var i = 0; i < allPlanetsData.length; i++) {
      final planetData = allPlanetsData[i];
      planets.add(PlanetVm(
          planet: Planet(
            name: planetData.name,
            radius: planetData.radius,
            orbitalRadius: planetData.orbitalRadius,
            location: Location(
              planetData.location.x,
              planetData.location.y,
              planetData.location.z,
            ),
          ),
          color: planetData.color,
          indicatorFactor: 1));
    }
    //TODO factor 与摄像机朝向有关
    //debug init
    for (var i = 0; i < planets.length; i++) {
      final angle = pi;
      final orbitalRadius = planets[i].planet.orbitalRadius;
      planets[i].planet.location =
          Location(cos(angle) * orbitalRadius, sin(angle) * orbitalRadius, 0);
    }
    // debug end
  }

  initRotationSensor() {
    // final rotationVector = ref.watch(rotationProvider);
    // rotationVector.when(
    //   loading: () {},
    //   error: (error, stack) {},
    //   data: (rotationVector) {
    //     cameraPerspective.setRotationFromQuaternion(three.Quaternion(
    //         rotationVector.x,
    //         rotationVector.y,
    //         rotationVector.z,
    //         rotationVector.cosTheta));
    //     render();
    //   },
    // );
    render();
    // renderInitialized = true;
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

  initPage() {
    aspect = width / (height / 2);

    scene = three.Scene();
    // debug
    var axes = three.AxesHelper(500);
    scene.add(axes);
//debug end

    //

    camera = three.PerspectiveCamera(50, aspect, 1, 25000);
    camera.position.x = 500;
    camera.position.y = 500;
    camera.position.z = 500;
    camera.lookAt(three.Vector3(0, 0, 0));

    cameraPerspective = three.PerspectiveCamera(50, aspect, 1, 25000);

    cameraPerspectiveHelper = three.CameraHelper(cameraPerspective);
    scene.add(cameraPerspectiveHelper);

    activeHelper = cameraPerspectiveHelper;

    // counteract different front orientation of cameras vs rig

    // cameraPerspective.rotation.y = Math.pi;

    // cameraRig = three.Group();

    // cameraRig.add(cameraPerspective);

    // scene.add(cameraRig);

    //

    var mesh2 = three.Mesh(three.SphereGeometry(150, 16, 8),
        three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": false}));
    mesh2.position.y = 250;
    mesh2.position.x = 250;
    mesh2.position.z = 0;

    var mesh3 = three.Mesh(three.SphereGeometry(100, 16, 8),
        three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": false}));
    mesh3.position.y = -250;
    mesh3.position.x = -250;
    mesh3.position.z = 0;
    // scene.add(mesh2);
    // scene.add(mesh3);

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

    // add planets
    // for (var planet in planets) {
    //   var mesh = three.Mesh(three.SphereGeometry(planet.radius, 16, 8),
    //       three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": false}));
    //   scene.add(mesh);
    // }
    for (var i = 0; i < planets.length; i++) {
      var planet = planets[i].planet;
      var color = planets[i].color;
      var mesh = three.Mesh(
          three.SphereGeometry(planet.radius, 16, 8),
          //TODO 外星站是隐身的
          three.MeshBasicMaterial({
            "color": color, // texture?
            "wireframe": false
          }));
      mesh.position.x = planet.location.x * 0.5;
      mesh.position.y = planet.location.y * 0.5;
      mesh.position.z = planet.location.z * 0.5;
      mesh.position;
      scene.add(mesh);
    }
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
