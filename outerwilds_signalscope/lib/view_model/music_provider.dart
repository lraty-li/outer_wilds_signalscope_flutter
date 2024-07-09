import 'package:just_audio/just_audio.dart';
import 'package:outerwilds_signalscope/constant/planets_data.dart';
import 'package:outerwilds_signalscope/view_model/cosine_provider.dart';
import 'package:outerwilds_signalscope/view_model/planets_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_provider.g.dart';

// @Riverpod(keepAlive: true)
@riverpod
//TODO dispose player on closing the app
class MusicPlayer extends _$MusicPlayer {
  Map<int, AudioPlayer> _players = {};
  @override
  Future<List<bool>> build() async {
    ref.onDispose(() => print("MusicPlayer dispose"));
    print("MusicPlayer builded");
    final planets = ref.read(planetListProvider);
    for (var i = 0; i < planets.length; i++) {
      if (planetMusicMap[i] != null) {
        var tmpPlayer = AudioPlayer();
        //TODO future
        await tmpPlayer.setAsset(planetMusicMap[i]!);
        tmpPlayer.setVolume(0);
        tmpPlayer.setLoopMode(LoopMode.all);
        _players[planets[i].id] = tmpPlayer;
      }
    }
    _players.forEach((key, value) => value.play());
    _initSensor();
    return List<bool>.filled(planets.length, false);
  }

  _initSensor() {
    ref.listen(cosinePlanetCameraProvider, (previous, next) {
      next.whenData((cosinValues) => updateData(cosinValues));
    });
  }

  void updateData(Map<int, double> cosinValues) {
    final planets = ref.read(planetListProvider);
    for (var i = 0; i < planets.length; i++) {
      double cosine = cosinValues[planets[i].id] ?? -1;
      //在180度内
      //TODO cosine 函数值使得声音“偏大”： 接近1的时候斜率小
      _players[planets[i].id]?.setVolume(cosine >= 0 ? cosine : 0);
    }
  }
}
