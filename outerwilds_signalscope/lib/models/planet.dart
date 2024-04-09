import 'package:outerwilds_signalscope/models/location.dart';
import 'package:outerwilds_signalscope/util/calc_period.dart';

class Planet {
  Planet({
    // required this.color,
    required this.location,
    required this.name,
    required this.orbitalRadius,
    required this.radius,
    this.parentBody,
  }) {
    // TODO终止条件
    // parentBody ??= Planet(
    //     name: "Sun",
    //     radius: 2001.75,
    //     orbitalRadius: 0,
    //     location: Location(0, 0, 0));
    // periodSeconds = calcPeriod(orbitalRadius); 
    //？ 卫星的周期也是这么算的？
  }
  // final int color;
  final String name;
  Location location;
  
  late final double periodSeconds;
  
  //环绕母星的半径
  final double orbitalRadius;

  //parentBody如果为空，为太阳
  late final Planet? parentBody;

  //自身半径
  final double radius;

  List<Planet> children = []; //因为要先更新母星的位置，所以用从上往下的结构存储
  
  Location willGoto(double time, Location parentLocation) {
    //TODO 根据周期，经过time之后到达什么位置, 参数：轨道
    //如何描述轨道？ 外星站是垂直黄道的
    //根据母星计算，那么得先更新母星的位置？
    //木炉这种都按照xoy 黄道平面计算吧

    //太阳：
    // 经过的时间模总周期-> 计算角度 ,或者直接保存角速度？
    // 角度 -> 正弦:y 余弦：x（方向）

    // 绕母星
    // 加上母星位置（向量计算）
    // 母星位置- 母星的母星（太阳）， 自己位置-母星位置。两向量相减
    // 如何优雅控制更新顺序，虽然说根据时间更新母星位置，结果是一致的，但是重复更新了

    location = Location(1, 1, 1);
    return location;
  }
}


enum PlanetEnum{
  TimberHearth,
}
