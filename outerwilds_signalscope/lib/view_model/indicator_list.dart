import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/constant/planets_data.dart';

class IndicatorData {
  IndicatorData({required this.factor, required this.visiablity});
  double factor;
  bool visiablity;
}

class IndicatorList extends Notifier<List<IndicatorData>> {
  @override
  List<IndicatorData> build() {
    return List<IndicatorData>.filled(
        planetsData.length, IndicatorData(factor: 0, visiablity: false));
  }
}
