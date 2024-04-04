import 'package:flutter/material.dart';
import 'package:outerwilds_signalscope/widgets/signal_indicator_view.dart';
import 'package:outerwilds_signalscope/widgets/three_demension_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            ThreeDView(),
            SignalIndicatorView(),
          ],
        ),
      ),
    );
  }
}
