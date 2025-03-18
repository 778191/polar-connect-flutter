/// Applies a finite impulse response (FIR) bandpass (5-15Hz) filter to the input signal using predefined filter coefficients.
///
/// This function takes a list of double values representing the input signal and applies a FIR filter
/// to it using a set of predefined filter coefficients. The filtered signal is returned as a list of double values.
///
/// The filtering process involves convolving the input signal with the filter coefficients. For each
/// sample in the input signal, the function computes a weighted sum of the current and previous samples,
/// where the weights are given by the filter coefficients.
///
/// The length of the output signal is the same as the input signal.
///
/// Parameters:
/// - `signal`: A list of double values representing the input signal to be filtered.
///
/// Returns:
/// - A list of double values representing the filtered signal.
List<double> filter(List<int> signal) {
  int signalLength = signal.length;
  List<double> filteredSignal = List.filled(signalLength, 0.0);
  List<double> filterCoefs = [
    0.00876060823922924,
    0.0048397038226516,
    0.00390111640179087,
    0.00118409582536312,
    -0.00286935515995156,
    -0.0072036494125729,
    -0.0104603685811388,
    -0.0114862281786845,
    -0.00988405200772962,
    -0.00630402631681813,
    -0.00228177245665016,
    0.000408326052253441,
    0.000625371882566526,
    -0.00146524875801666,
    -0.00432475145391798,
    -0.00571752166622161,
    -0.00388586736673618,
    0.00137272966861239,
    0.00834526669117249,
    0.0140985443101397,
    0.0159825450434944,
    0.0131945114628533,
    0.0074827327682026,
    0.00244254834131365,
    0.00161170245650691,
    0.00631374875743498,
    0.0144746025248761,
    0.0212927029126071,
    0.0216537640021526,
    0.0131545841267102,
    -0.00202422458319563,
    -0.01765036031642,
    -0.0264103328972264,
    -0.0241422814739726,
    -0.0128327977446565,
    -0.000591692080594337,
    0.00195841807031718,
    -0.0124789621103529,
    -0.0428106667929533,
    -0.0780480046893532,
    -0.100849612444228,
    -0.0949474392861735,
    -0.0532921633382649,
    0.0170995366923714,
    0.0962462548414285,
    0.158305794752103,
    0.181767163809825,
    0.158305794752103,
    0.0962462548414285,
    0.0170995366923714,
    -0.0532921633382649,
    -0.0949474392861735,
    -0.100849612444228,
    -0.0780480046893532,
    -0.0428106667929533,
    -0.0124789621103529,
    0.00195841807031718,
    -0.000591692080594337,
    -0.0128327977446565,
    -0.0241422814739726,
    -0.0264103328972264,
    -0.01765036031642,
    -0.00202422458319563,
    0.0131545841267102,
    0.0216537640021526,
    0.0212927029126071,
    0.0144746025248761,
    0.00631374875743498,
    0.00161170245650691,
    0.00244254834131365,
    0.0074827327682026,
    0.0131945114628533,
    0.0159825450434944,
    0.0140985443101397,
    0.00834526669117249,
    0.00137272966861239,
    -0.00388586736673618,
    -0.00571752166622161,
    -0.00432475145391798,
    -0.00146524875801666,
    0.000625371882566526,
    0.000408326052253441,
    -0.00228177245665016,
    -0.00630402631681813,
    -0.00988405200772962,
    -0.0114862281786845,
    -0.0104603685811388,
    -0.0072036494125729,
    -0.00286935515995156,
    0.00118409582536312,
    0.00390111640179087,
    0.0048397038226516,
    0.00876060823922924
  ];

  for (int i = 0; i < signalLength; i++) {
    double sum = 0.0;
    for (int j = 0; j < filterCoefs.length; j++) {
      if (i - j >= 0) {
        sum += filterCoefs[j] * signal[i - j];
      }
    }
    filteredSignal[i] = sum;
  }

  return filteredSignal;
}

/// Computes the derivative of a given signal.
///
/// This function takes a list of doubles representing a signal and calculates
/// the derivative of the signal. The derivative is computed as the difference
/// between consecutive elements in the signal.
///
/// - Parameter signal: A list of doubles representing the input signal.
/// - Returns: A list of doubles representing the derivative of the input signal.
List<double> derivative(List<double> signal) {
  int signalLength = signal.length;
  List<double> derivativeSignal = List.filled(signalLength, 0.0);

  for (int i = 0; i < signalLength - 1; i++) {
    derivativeSignal[i] = signal[i + 1] - signal[i];
  }

  return derivativeSignal;
}

/// Squares each element in the given signal list.
///
/// This function takes a list of doubles representing a signal and returns a
/// new list where each element is the square of the corresponding element in
/// the input list.
///
/// - Parameter signal: A list of doubles representing the input signal.
/// - Returns: A list of doubles where each element is the square of the
///   corresponding element in the input signal.
List<double> square(List<double> signal) {
  int signalLength = signal.length;
  List<double> squaredSignal = List.filled(signalLength, 0.0);

  for (int i = 0; i < signalLength; i++) {
    squaredSignal[i] = signal[i] * signal[i];
  }

  return squaredSignal;
}

/// Computes the moving average of a given signal using a specified window size.
///
/// The function takes a list of doubles representing the signal and applies a
/// moving average filter with a window size of 30 samples. This is suitable for
/// a 150ms window size at a 130Hz sampling rate.
///
/// - Parameter signal: A list of doubles representing the input signal.
/// - Returns: A list of doubles representing the signal after applying the moving average filter.
List<double> movingAverage(List<double> signal) {
  // 150ms window size for 130Hz sampling rate --> 20 samples (approx)
  int windowSize = 30;
  int signalLength = signal.length;
  List<double> movingAverageSignal = List.filled(signalLength, 0.0);

  for (int i = 0; i < signalLength; i++) {
    double sum = 0.0;
    for (int j = 0; j < windowSize; j++) {
      if (i - j >= 0) {
        sum += signal[i - j];
      }
    }
    movingAverageSignal[i] = sum / windowSize;
  }

  return movingAverageSignal;
}

/// Finds the R-peaks in an ECG signal using a simple peak detection algorithm.
///
/// This function processes the input ECG signal to identify the R-peaks, which
/// are the highest points in the QRS complex of the ECG waveform. It uses a
/// refractory period to avoid detecting multiple peaks within a short time frame.
///
/// - Parameters:
///   - signal: A list of doubles representing the ECG signal.
/// - Returns: A list of integers representing the indices of the detected R-peaks.
///
/// The algorithm works as follows:
/// 1. Iterates through the signal to find local maxima (potential R-peaks).
/// 2. Applies a refractory period to ensure that consecutive peaks are separated
///    by at least the refractory period.
List<int> findRPeaks(List<double> signal) {
  int refractoryPeriod = 65; // 500ms at 130Hz sampling rate
  int signalLength = signal.length;
  List<int> peaks = List.empty(growable: true);

  for (int i = 1; i < signalLength - 1; i++) {
    if (signal[i] > signal[i - 1] && signal[i] > signal[i + 1]) {
      peaks.add(i);
    }
  }

  for (int i = 0; i < peaks.length - 1; i++) {
    if (peaks[i + 1] - peaks[i] < refractoryPeriod) {
      if (signal[peaks[i + 1]] > signal[peaks[i]]) {
        peaks.removeAt(i);
      } else {
        peaks.removeAt(i + 1);
      }
      i--;
    }
  }

  return peaks;
}
