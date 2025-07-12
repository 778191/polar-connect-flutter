import 'dart:math';

double calcularSD1(List<int> rrIntervals) {
  if (rrIntervals.length < 2) return 0.0;

  List<double> diffs = [];
  for (int i = 1; i < rrIntervals.length; i++) {
    diffs.add((rrIntervals[i] - rrIntervals[i - 1]).toDouble());
  }

  double meanDiff = diffs.reduce((a, b) => a + b) / diffs.length;
  num sqSum = diffs.map((x) => pow(x - meanDiff, 2)).reduce((a, b) => a + b);
  return sqrt(sqSum / diffs.length) / sqrt(2);
}

double calcularSD2(List<int> rrIntervals, double sd1) {
  if (rrIntervals.length < 2) return 0.0;

  double mean = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
  num sqSum = rrIntervals.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b);
  double sdrr = sqrt(sqSum / rrIntervals.length);

  return sqrt(2 * sdrr * sdrr - sd1 * sd1);
}