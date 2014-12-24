public class Float {
  static float MAX_VALUE = 3.4028234663852886E38f;
  static int  compare(float f1, float f2) {
    if (f1 == f2) {
      return 0;
    }
    if (f1 > f2) {
      return 1;
    }
    else if (f1 < f2) {
      return -1;
    }
  }
}
