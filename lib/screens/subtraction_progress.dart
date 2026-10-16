// Keeps track of which Subtraction levels are unlocked.
import '../data/app_store.dart';

class SubtractionProgress {
  static int get unlockedLevel => AppStore.instance.unlockLevel('subtraction');
  static set unlockedLevel(int value) => AppStore.instance.setUnlock('subtraction', value);
}