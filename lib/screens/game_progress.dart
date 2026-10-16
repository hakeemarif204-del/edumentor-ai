import '../data/app_store.dart';

class GameProgress {
  static int get unlockedLevel => AppStore.instance.unlockLevel('feedFish');
  static set unlockedLevel(int value) => AppStore.instance.setUnlock('feedFish', value);
}