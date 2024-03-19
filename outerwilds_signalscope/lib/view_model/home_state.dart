import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/three.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:sensors_plus/sensors_plus.dart';

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
  late three.Mesh mesh;

  late three.Camera cameraPerspective;

  late three.Group cameraRig;

  late three.Camera activeCamera;
  late three.CameraHelper activeHelper;

  late three.CameraHelper cameraPerspectiveHelper;

  late Function mySetstate;

  int frustumSize = 600;

  double dpr = 1.0;

  num aspect = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;
  late final bool mykisweb;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

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

    mySetstate(() {});

    // Wait for web  //? centain time?
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initScene() {
    initRenderer();
    initPage();
    initgyroscope();
  }

  initgyroscope() {
    gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((event) {
      //校准？
      activeCamera.rotateX(event.x);
      activeCamera.rotateY(event.y);
      activeCamera.rotateZ(event.z);
      render();
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
    aspect = width / (height  /2);

    scene = three.Scene();

    //

    camera = three.PerspectiveCamera(50, aspect, 1, 10000);
    camera.position.z = 2500;

    cameraPerspective = three.PerspectiveCamera(50, aspect, 150, 1000);

    cameraPerspectiveHelper = three.CameraHelper(cameraPerspective);
    scene.add(cameraPerspectiveHelper);

    activeCamera = cameraPerspective;
    activeHelper = cameraPerspectiveHelper;

    // counteract different front orientation of cameras vs rig

    // cameraPerspective.rotation.y = three.Math.pi;

    cameraRig = three.Group();

    cameraRig.add(cameraPerspective);

    scene.add(cameraRig);

    //

    mesh = three.Mesh(three.SphereGeometry(100, 16, 8),
        three.MeshBasicMaterial({"color": 0x31A174, "wireframe": false}));
    scene.add(mesh);

    var mesh2 = three.Mesh(three.SphereGeometry(50, 16, 8),
        three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": false}));
    mesh2.position.y = 150;
    mesh.add(mesh2);

    var mesh3 = three.Mesh(three.SphereGeometry(5, 16, 8),
        three.MeshBasicMaterial({"color": 0x31A174, "wireframe": false}));
    mesh3.position.z = 150;
    // cameraRig.add(mesh3);

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
    render();
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    renderer!.clear();

    activeHelper.visible = false;

    renderer!.setViewport(0, 0, width, height / 2);
    renderer!.render(scene, activeCamera);

    activeHelper.visible = true;

    renderer!.setViewport(0, height / 2, width, height / 2);
    renderer!.render(scene, camera);

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
