import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outerwilds_signalscope/view_model/home_state.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool disposed = false;
  var homestate = HomeState();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initSize(context, homestate);
    return MaterialApp(
      home: Scaffold(
        body: _build(context),
        floatingActionButton: ElevatedButton(
          child: Text("set state"),
          onPressed: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    var width = homestate.width;
    var height = homestate.height;
    var three3dRender = homestate.three3dRender;

    //testing code
    var indicatorFactors = homestate.indicatorFactors;
    for (var index = 0; index < indicatorFactors.length; index += 1) {
      indicatorFactors[index] = index / 10;
    }
    //testing code end

    return Stack(
      children: [
        // Container(
        //     width: width,
        //     height: height,
        //     color: Colors.black,
        //     child: Builder(builder: (BuildContext context) {
        //       if (kIsWeb) {
        //         return three3dRender.isInitialized
        //             ? HtmlElementView(
        //                 viewType: three3dRender.textureId!.toString())
        //             : const CircularProgressIndicator();
        //       } else {
        //         return three3dRender.isInitialized
        //             ? Texture(textureId: three3dRender.textureId!)
        //             : const CircularProgressIndicator();
        //       }
        //     })),
        ..._buildIndicators(homestate)
      ],
    );
  }

  List<SignalCircleIndicator> _buildIndicators(HomeState state) {
    {
      List<double> indicatorsData = homestate.indicatorFactors;
      List<SignalCircleIndicator> indicators = [];
      for (var i = 0; i < indicatorsData.length; i++) {
        indicators.add(SignalCircleIndicator(
          arcCtlFactor: indicatorsData[i],
          arcLengthFactor:  .2,
          arcColor: Colors.black,
        ));
      }
      return indicators;
    }
  }

  _initSize(BuildContext context, HomeState state) async {
    if (state.screenSize != null) {
      return;
    }
    state.mySetstate = setState; //TODO better init

    final mqd = MediaQuery.of(context);

    state.screenSize = mqd.size;
    state.dpr = mqd.devicePixelRatio;

    state.mykisweb = kIsWeb;
    await state.initPlatformState();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    homestate.render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");

    disposed = true;
    homestate.three3dRender.dispose();

    super.dispose();
  }
}
