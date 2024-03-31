import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/indicators_provider.dart';
import 'package:outerwilds_signalscope/view_model/sensor_provider.dart';
import 'package:outerwilds_signalscope/view_model/threeD_provider.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    // ref.read(counterProvider);
  }

  @override
  Widget build(BuildContext context) {
    _initSize(context, ref, setState);
    return MaterialApp(
      home: Scaffold(
        body: _build(ref),
        floatingActionButton: ElevatedButton(
          child: Text("set state"),
          onPressed: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _build(WidgetRef ref) {
    final rotationVector = ref.watch(rotationProvider);
    return Stack(
      children: [
        _build3dView(ref),
        ..._buildIndicators(ref),
      ],
    );
  }

  List<Visibility> _buildIndicators(WidgetRef ref) {
    {
      List<Visibility> indicators = [];
      var indicatorCount = ref.read(indicatorListProvider).length;
      for (var index = 0; index < indicatorCount; index++) {
        var indicatorData = ref.watch(indicatorListProvider)[index];
        //TODO 判断是否需要绘制
        // 参数用到两个位置，会rebuild多少次?
        var indicatorWidget = Visibility(
          visible: indicatorData.visiablity,
          child: SignalCircleIndicator(
            arcCtlFactor: indicatorData.factor,
            arcLengthFactor: .2,
            arcColor: Colors.red,
            // arcColor: Color(planets[i].color),
          ),
        );
        indicators.add(indicatorWidget);
      }
      return indicators;
    }
  }

  Widget _build3dView(WidgetRef ref) {
    return Container(
        width: ref.read(threeDSceneProvider).width,
        height: ref.read(threeDSceneProvider).height,
        color: Colors.black,
        child: Builder(builder: (BuildContext context) {
          return ref.watch(threeDSceneProvider
                  .select((state) => state.renderInitialized))
              ? Texture(
                  textureId:
                      ref.read(threeDSceneProvider).three3dRender.textureId!)
              : const CircularProgressIndicator();
        }));
  }

  _initSize(BuildContext context, WidgetRef ref,Function setState) async {
    ThreeDScene scene = ref.read(threeDSceneProvider);
    if (scene.screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    await scene.initPlatformState(
      mqd.size,
      mqd.devicePixelRatio,
      setState
    );
  }

  // @override
  // void dispose() {
  //   print(" dispose ............. ");

  //   disposed = true;
  //   homestate.three3dRender.dispose(); //TODO ref dispose

  //   super.dispose();
  // }
}
