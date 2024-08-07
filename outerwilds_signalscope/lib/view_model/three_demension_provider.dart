import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:outerwilds_signalscope/view_model/device_rotation_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:three_dart/three_dart.dart' as three;
part 'three_demension_provider.g.dart';

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

  bool renderInitialized = false;
  bool sizeInitialized = false;

  @override
  bool build() {
    ref.keepAlive();
    ref.onDispose(() {
      print("thrre dispose");
    });
    //is render ready, TODO split apart?
    return false;
  }

  //https://github.com/wasabia/three_dart/blob/main/example/lib/webgl_camera.dart
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(Size size, double devicePixelRatio) async {
    print("initPlatformState");
    width = size.width;
    height = size.height;
    dpr = devicePixelRatio;
    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };
    sizeInitialized = true;

    await three3dRender.initialize(options: options);
    renderInitialized = true;

    // Wait for web  //? centain time?
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initScene() async {
    initRenderer();
    initPage();
    initRotationSensor();
    state = true;
  }

  initRotationSensor() {
    ref.listen(deviceRotationProvider, (previous, next) {
      next.when(
        loading: () {},
        error: (error, stack) {},
        data: (rotationVector) {
          cameraPerspective.setRotationFromQuaternion(three.Quaternion(
            rotationVector[0],
            rotationVector[1],
            rotationVector[2],
            rotationVector[3],
          ));
          render();
          print("rotation event");
        },
      );
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
    camera.position.x = 1500;
    camera.position.y = 1500;
    camera.position.z = 1500;
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

    final planets = ref.watch(planetListProvider);
    // add planets
    for (var planet in planets) {
      final planetLocation = planet.location;
      var mesh = three.Mesh(three.SphereGeometry(planet.radius, 16, 8),
          three.MeshBasicMaterial({"color": planet.color, "wireframe": false}));
      mesh.position.set(planetLocation.x, planetLocation.y, planetLocation.z);
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
