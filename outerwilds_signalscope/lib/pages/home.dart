import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outerwilds_signalscope/view_model/home_state.dart';

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
    return MaterialApp(
      home: Scaffold(body: Builder(
        builder: (BuildContext context) {
          _initSize(context, homestate);
          return SingleChildScrollView(child: _build(context));
        },
      )),
    );
  }

  Widget _build(BuildContext context) {
    var width = homestate.width;
    var height = homestate.height;
    var three3dRender = homestate.three3dRender;
    return Column(
      children: [
        Stack(
          children: [
            Container(
                width: width,
                height: height,
                color: Colors.black,
                child: Builder(builder: (BuildContext context) {
                  if (kIsWeb) {
                    return three3dRender.isInitialized
                        ? HtmlElementView(
                            viewType: three3dRender.textureId!.toString())
                        : const CircularProgressIndicator();
                  } else {
                    return three3dRender.isInitialized
                        ? Texture(textureId: three3dRender.textureId!)
                        : const CircularProgressIndicator();
                  }
                })),
          ],
        ),
      ],
    );
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
