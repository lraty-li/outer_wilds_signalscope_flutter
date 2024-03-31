import 'package:outerwilds_signalscope/constant/universal.dart';
import 'package:three_dart/three3d/math/math.dart';

//https://www.reddit.com/r/outerwilds/comments/dhx2if/comment/iqk6jba/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
//T = tau*sqrt(r^3/(4*10^8))

double calcPeriod(double raduis) {
  return tau * Math.sqrt((raduis * 3) / (4 * 10 ^ 8));
}
