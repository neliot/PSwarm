class Helper {

  Helper() {
  }

  public double rtodp(double a, int dp) {
    double p = Math.pow(10.0, dp);
    a = Math.rint(a * p) / p;
    return a;
  }
}