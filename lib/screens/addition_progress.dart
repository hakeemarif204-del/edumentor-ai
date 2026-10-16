import '../data/app_store.dart';

class AdditionProgress {
  static int get unlockedLevel => AppStore.instance.unlockLevel('addition');
  static set unlockedLevel(int value) => AppStore.instance.setUnlock('addition', value);
}