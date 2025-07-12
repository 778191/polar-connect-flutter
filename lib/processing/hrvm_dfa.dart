import 'dart:math';


double calcularDFA(List<int> rrIntervals) {
  if (rrIntervals.length < 10) return 0.0;

  // 1. Serie integrada
  double rrMean = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
  List<double> y = [];
  double sum = 0.0;
  for (var rr in rrIntervals) {
    sum += (rr - rrMean);
    y.add(sum);
  }

  List<int> scales = [4, 8, 16, 32, 64];
  List<double> avgRMS = [];

  for (int scale in scales) {
    if (scale >= y.length) continue;

    int segments = y.length ~/ scale;
    if (segments < 1) continue;

    List<double> rmsList = [];

    for (int s = 0; s < segments; s++) {
      int start = s * scale;
      List<double> segment = y.sublist(start, start + scale);

      List<double> x = List.generate(scale, (i) => i.toDouble());
      double xMean = x.reduce((a, b) => a + b) / scale;
      double yMean = segment.reduce((a, b) => a + b) / scale;

      double num = 0.0;
      double den = 0.0;
      for (int i = 0; i < scale; i++) {
        num += (x[i] - xMean) * (segment[i] - yMean);
        den += pow(x[i] - xMean, 2);
      }
      double slope = num / den;
      double intercept = yMean - slope * xMean;

      double rms = 0.0;
      for (int i = 0; i < scale; i++) {
        double detrended = segment[i] - (slope * x[i] + intercept);
        rms += detrended * detrended;
      }
      rms = sqrt(rms / scale);
      if (rms > 0) rmsList.add(rms);
    }

    if (rmsList.isNotEmpty) {
      double meanRMS = rmsList.reduce((a, b) => a + b) / rmsList.length;
      avgRMS.add(meanRMS);
    }
  }

  if (avgRMS.length < 2) return 0.0;

  List<double> logScales = [];
  List<double> logRMS = [];

  for (int i = 0; i < avgRMS.length; i++) {
    logScales.add(log(scales[i].toDouble()));
    logRMS.add(log(avgRMS[i]));
  }

  // Regresión lineal
  int N = logScales.length;
  double xMean = logScales.reduce((a, b) => a + b) / N;
  double yMean = logRMS.reduce((a, b) => a + b) / N;

  double num = 0.0;
  double den = 0.0;
  for (int i = 0; i < N; i++) {
    num += (logScales[i] - xMean) * (logRMS[i] - yMean);
    den += pow(logScales[i] - xMean, 2);
  }

  if (den == 0.0) return 0.0;
  double alpha = num / den;
  return alpha;
}