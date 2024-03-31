import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outerwilds_signalscope/models/planet.dart';
import 'package:outerwilds_signalscope/view_model/home_state.dart';
import 'package:outerwilds_signalscope/view_model/planet_view.dart';
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
    return Stack(
      children: [
        _build3dView(homestate),
        ..._buildIndicators(homestate),
      ],
    );
  }

  List<SignalCircleIndicator> _buildIndicators(HomeState state) {
    {
      List<PlanetVm> planets = homestate.planets;
      List<SignalCircleIndicator> indicators = [];
      for (var i = 0; i < planets.length; i++) {
        //TODO 判断是否需要绘制
        indicators.add(SignalCircleIndicator(
          arcCtlFactor: planets[i].indicatorFactor,
          arcLengthFactor: .2,
          arcColor: Colors.red,
          // arcColor: Color(planets[i].color),
        ));
      }
      return indicators;
    }
  }

  Widget _build3dView(HomeState homestate) {
    var width = homestate.width;
    var height = homestate.height;
    var three3dRender = homestate.three3dRender;
    return Container(
        width: width,
        height: height,
        color: Colors.black,
        child: Builder(builder: (BuildContext context) {
          if (kIsWeb) {
            return three3dRender.isInitialized
                ? HtmlElementView(viewType: three3dRender.textureId!.toString())
                : const CircularProgressIndicator();
          } else {
            return three3dRender.isInitialized
                ? Texture(textureId: three3dRender.textureId!)
                : const CircularProgressIndicator();
          }
        }));
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

  @override
  void dispose() {
    print(" dispose ............. ");

    disposed = true;
    homestate.three3dRender.dispose();

    super.dispose();
  }
}
