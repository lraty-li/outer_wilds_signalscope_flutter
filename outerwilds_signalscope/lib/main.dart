import 'package:flutter/material.dart';
import 'package:outerwilds_signalscope/pages/home.dart';
import 'dart:ui'; //window需要import ui库

// https://www.jianshu.com/p/4f0651241956
//debug的时候加载比较久？
void main() {
  //如果size是0，则设置回调，在回调中runApp
  //window. 弃用 This feature was deprecated after v3.7.0-32.0.pre 终于要来了吗多窗口
  final view = PlatformDispatcher.instance.views.first;
  if (view.physicalSize.isEmpty) {
    PlatformDispatcher.instance.onMetricsChanged = () {
      //在回调中，size仍然有可能是0
      if (!view.physicalSize.isEmpty) {
        PlatformDispatcher.instance.onMetricsChanged = null;
        _runApp();
      }
    };
  } else {
    //如果size非0，则直接runApp
    _runApp();
  }
}

void _runApp() {
  runApp(HomePage());
}
