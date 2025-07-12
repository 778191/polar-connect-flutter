import 'dart:math';

double calcularRMSSD(List<int> rPeakTimestamps) {
  if (rPeakTimestamps.length < 3) return 0.0;

  List<int> rrIntervals = [];
  for (int i = 1; i < rPeakTimestamps.length; i++) {
    rrIntervals.add(rPeakTimestamps[i] - rPeakTimestamps[i - 1]);
  }

  double sumSquares = 0.0;
  for (int i = 1; i < rrIntervals.length; i++) {
    int diff = rrIntervals[i] - rrIntervals[i - 1];
    sumSquares += diff * diff;
  }

  return sqrt(sumSquares / (rrIntervals.length - 1));
}