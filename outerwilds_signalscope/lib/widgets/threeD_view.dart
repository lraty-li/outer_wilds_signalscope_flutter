import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/threeD_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ThreeDView extends ConsumerWidget {
  const ThreeDView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _initSize(context, ref);
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(threeDSceneProvider)) {
          return SizedBox(
            width: ref.watch(
                threeDSceneProvider.notifier.select((value) => value.width)),
            height: ref.watch(
                threeDSceneProvider.notifier.select((value) => value.height)),
            child: Texture(
                textureId: ref
                    .watch(threeDSceneProvider.notifier)
                    .three3dRender
                    .textureId!),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
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
