import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/music_provider.dart';
import 'package:outerwilds_signalscope/view_model/three_demension_provider.dart';

class ThreeDView extends ConsumerWidget {
  const ThreeDView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO 单独创建一个view？或者往上放到main 的 init之类的
    final musicProvider = ref.watch(musicPlayerProvider);

    print("3d view build");
    _initSize(context, ref);
    //TODO not good, threeDSceneReady is the actual notifier
    final threeDScene = ref.watch(threeDSceneProvider.notifier);
    final threeDSceneReady = ref.watch(threeDSceneProvider);
    final width = threeDScene.width;
    final height = threeDScene.height;
    if (threeDSceneReady) {
      final textureId = threeDScene.three3dRender.textureId!;
      return SizedBox(
        width: width,
        height: height,
        child: Texture(textureId: textureId),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  _initSize(BuildContext context, WidgetRef ref) async {
    ThreeDScene scene = ref.read(threeDSceneProvider.notifier);
    if (scene.sizeInitialized) return;
    print("_initSize");
    if (scene.screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    await scene.initPlatformState(mqd.size, mqd.devicePixelRatio);
  }
}
