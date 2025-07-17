import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:polar_connect/widgets/custom_buttons.dart';
import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:polar_connect/widgets/custom_scaffold.dart';
import 'package:polar_connect/widgets/custom_toast.dart';
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:polar/polar.dart';
import 'package:sprintf/sprintf.dart';
import '../widgets/chart.dart';
import '../processing/pan_tompkins.dart';
import '../processing/hrvm_rmssd.dart';
import '../processing/hrvm_sd1_sd2.dart';
import '../processing/hrvm_dfa.dart';


class PolarConnect extends StatefulWidget {
  @override
  PolarConnectState createState() => PolarConnectState();
}

class PolarConnectState extends State<PolarConnect> {
  final polar = Polar();
  PolarExerciseEntry? exerciseEntry;

  static int _fs = 130; // Sampling rate.
  static int _displayLength = _fs * 6; // Window length to display [seconds].

  bool _isDeviceConnected = false; // Chart render state.
  bool _isRecording = false; // Recording state.
  bool _debug = false; // Debug state.
  int? _batteryLevel = null; // Battery level.
  int? _hr = null; // Heart rate.
  int? _hrFromECG = null; // Heart rate computed from ECG.
  String? _identifier; // Selected device identifier.
  deviceType? _deviceType; // Selected device type.
  List<String> _deviceIds = []; // List of device identifiers.
  List<String> _deviceNames = []; // List of device names.
  List<deviceType> _deviceTypes = []; // List of device types.
  Timer? _autoSaveTimer;

  // Plot arrays
  List<SensorValue> _plotPPGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotECGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotFilteredECGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotDerivativeECGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotSquaredECGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotAveragedECGValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotRPeaks = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotACCValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotGyroValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);
  List<SensorValue> _plotMagValues = List<SensorValue>.filled(
      _displayLength, SensorValue(null, null),
      growable: false);

  // Recording arrays
  List<int> _recordPPGValues = List<int>.empty(growable: true);
  List<int> _recordPPGTimestamps = List<int>.empty(growable: true);
  List<int> _recordECGValues = List<int>.empty(growable: true);
  List<int> _recordECGTimestamps = List<int>.empty(growable: true);
  List<List<int>> _recordACCValues = List<List<int>>.empty(growable: true);
  List<int> _recordACCTimestamps = List<int>.empty(growable: true);
  List<List<double>> _recordGyroValues =
      List<List<double>>.empty(growable: true);
  List<int> _recordGyroTimestamps = List<int>.empty(growable: true);
  List<List<double>> _recordMagValues =
      List<List<double>>.empty(growable: true);
  List<int> _recordMagTimestamps = List<int>.empty(growable: true);

  // Auxiliary arrays
  List<int> _ECGValues = List<int>.filled(_displayLength, 0, growable: false);
  List<DateTime> _timestamps =
      List<DateTime>.filled(_displayLength, DateTime.now(), growable: false);
  List<double> _filteredECGValues =
      List<double>.filled(_displayLength, 0, growable: false);
  List<double> _derivativeECGValues =
      List<double>.filled(_displayLength, 0, growable: false);
  List<double> _squaredECGValues =
      List<double>.filled(_displayLength, 0, growable: false);
  List<double> _averagedECGValues =
      List<double>.filled(_displayLength, 0, growable: false);
  List<int> _rpeaks = List<int>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermission();
    _addListeners();
    _autoSaveTimer = Timer.periodic(Duration(minutes: 15), (Timer t) {
    _saveRecord();
  });
  }


  @override
  void dispose() {
    if (_identifier != null) {
      polar.disconnectFromDevice(_identifier!);
    }
    _deviceIds.clear();
    _deviceNames.clear();
    _clearDeviceValues();
    _removeListeners();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double cardSeparation = 0.1 * displayWidth;

    return CustomScaffold(
      title: 'Polar Connect',
      body: _deviceIds.isEmpty
          ? InfoBox(
              text:
                  "Pair your Polar device with Polar Flow app. Then, tap on the device card to connect.")
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 0.07 * displayWidth,
                        vertical: displayHeight * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CustomCardRow per each device on deviceIds.
                        for (var deviceId in _deviceIds)
                          if (!_isDeviceConnected ||
                              (_isDeviceConnected && _identifier == deviceId))
                            DeviceCard(
                              height: 0.08 * displayHeight,
                              icon:
                                  _deviceTypes[_deviceIds.indexOf(deviceId)] ==
                                          deviceType.H10
                                      ? Icons.monitor_heart_outlined
                                      : Icons.watch,
                              text: _deviceNames[_deviceIds.indexOf(deviceId)],
                              batteryLevel: _batteryLevel,
                              connected:
                                  _isDeviceConnected && _identifier == deviceId,
                              onPressed: () =>
                                  _handleDeviceCardPressed(deviceId),
                            ),
                        SizedBox(height: cardSeparation),
                        if (_isDeviceConnected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AccentButton(
                                  width: 0.4 * displayWidth,
                                  text: _isRecording
                                      ? "Stop recording"
                                      : "Start recording",
                                  onPressed: () => {
                                        if (_isRecording)
                                          {
                                            _isRecording = false,
                                            _saveRecord(),
                                          }
                                        else
                                          _isRecording = true
                                      }),
                              WhiteButton(
                                  width: 0.4 * displayWidth,
                                  text: _debug
                                      ? "Hide debug signals"
                                      : "Show debug signals",
                                  onPressed: () => {
                                        if (_debug)
                                          {
                                            _debug = false,
                                          }
                                        else
                                          _debug = true
                                      }),
                            ],
                          ),
                        SizedBox(height: cardSeparation),
                        if (_isDeviceConnected)
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'HR from device: ${_hr}',
                              style: GoogleFonts.roboto(
                                color: CustomColors.tertiary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (_isDeviceConnected && _deviceType == deviceType.H10)
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'HR computed: $_hrFromECG',
                              style: GoogleFonts.roboto(
                                color: CustomColors.tertiary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (_isDeviceConnected)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.02 * displayHeight,
                            ),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _deviceType == deviceType.H10
                                          ? 'ECG'
                                          : 'PPG',
                                      style: GoogleFonts.roboto(
                                        color: CustomColors.tertiary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                if (_isDeviceConnected)
                                  _deviceType == deviceType.H10
                                      ? Chart(_plotECGValues)
                                      : Chart(_plotPPGValues),
                              ],
                            ),
                          ),
                        if (_isDeviceConnected &&
                            _deviceType == deviceType.H10 &&
                            _debug)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.02 * displayHeight,
                            ),
                            child: Column(children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ECG filtered",
                                    style: GoogleFonts.roboto(
                                      color: CustomColors.tertiary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              if (_isDeviceConnected)
                                Chart(_plotFilteredECGValues),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ECG derivative",
                                    style: GoogleFonts.roboto(
                                      color: CustomColors.tertiary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              if (_isDeviceConnected)
                                Chart(_plotDerivativeECGValues),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ECG squared",
                                    style: GoogleFonts.roboto(
                                      color: CustomColors.tertiary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              if (_isDeviceConnected)
                                Chart(_plotSquaredECGValues),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ECG averaged",
                                    style: GoogleFonts.roboto(
                                      color: CustomColors.tertiary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                              if (_isDeviceConnected)
                                Stack(
                                  children: <Widget>[
                                    Chart(_plotAveragedECGValues),
                                    Chart(_plotRPeaks, markersVisible: true),
                                  ],
                                ),
                            ]),
                          ),
                        if (_isDeviceConnected)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.02 * displayHeight,
                            ),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Accelerometer',
                                      style: GoogleFonts.roboto(
                                        color: CustomColors.tertiary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                Chart(_plotACCValues),
                              ],
                            ),
                          ),
                        if (_isDeviceConnected &&
                            _deviceType == deviceType.Sense)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.02 * displayHeight,
                            ),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Gyroscope',
                                      style: GoogleFonts.roboto(
                                        color: CustomColors.tertiary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                Chart(_plotGyroValues),
                              ],
                            ),
                          ),
                        if (_isDeviceConnected &&
                            _deviceType == deviceType.Sense)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.02 * displayHeight,
                            ),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Magnetometer',
                                      style: GoogleFonts.roboto(
                                        color: CustomColors.tertiary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                Chart(_plotMagValues),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ))),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      // Disconnect from device if connected.
      if (_isDeviceConnected) {
        await polar.disconnectFromDevice(_identifier!);
      }

      _removeListeners();

      // Clear device values and lists.
      setState(() {
        _clearDeviceValues();
        _deviceIds.clear();
        _deviceNames.clear();
        _deviceTypes.clear();
      });

      _addListeners();
    } catch (e) {
      print('Error refreshing: $e');
    }
  }

  void _addListeners() {
    // Listen for device search events.r
    polar.searchForDevice().listen((e) {
      print('Found device in scan: ${e.name}');
      if (!_deviceIds.contains(e.deviceId)) {
        setState(() {
          _deviceIds.add(e.deviceId);
          _deviceNames.add(e.name);
          if (RegExp(r'oh1', caseSensitive: false).hasMatch(e.name)) {
            _deviceTypes.add(deviceType.OH1);
          } else if (RegExp(r'h10', caseSensitive: false).hasMatch(e.name)) {
            _deviceTypes.add(deviceType.H10);
          } else {
            _deviceTypes.add(deviceType.Sense);
          }
        });
      }
    });

    // Listen for device battery level.
    polar.batteryLevel.listen((e) {
      print('Battery: ${e.level}');
      _batteryLevel = e.level;
    });

    // Listen for device connection events.
    polar.deviceConnecting
        .listen((e) => print('Device connecting: ${e.deviceId}'));
    polar.deviceConnected
        .listen((e) => print('Device connected: ${e.deviceId}'));

    // Listen for device disconnection events.
    polar.deviceDisconnected.listen((e) {
      print('Device disconnected: ${e.info.deviceId}');
      setState(() {
        _clearDeviceValues();
      });
    });
  }

  void _removeListeners() {
    polar.searchForDevice().listen((e) {}).cancel();
    polar.batteryLevel.listen((e) {}).cancel();
    polar.deviceConnecting.listen((e) {}).cancel();
    polar.deviceConnected.listen((e) {}).cancel();
    polar.deviceDisconnected.listen((e) {}).cancel();
  }

  void _handleDeviceCardPressed(String deviceId) {
    if (_isDeviceConnected && _identifier == deviceId) {
      // Tap on connected device
      _disconnectDevice();
    } else if (_isDeviceConnected) {
      // Tap on disconnected device and another device connected
      _disconnectDevice();
      _connectDevice(deviceId);
    } else {
      // Tap on disconnected device and no device connected
      _connectDevice(deviceId);
    }
  }

  void _connectDevice(deviceId) async {
    setState(() {
      _identifier = deviceId;
      _deviceType = _deviceTypes[_deviceIds.indexOf(deviceId)];
      _isDeviceConnected = true;
    });
    polar.connectToDevice(_identifier!);
    print('Connected to device: $_identifier');
    _streamWhenReady();
  }

  void _disconnectDevice() {
    polar.disconnectFromDevice(_identifier!);
    setState(() {
      _clearDeviceValues();
    });
  }

  void _clearDeviceValues() {
    setState(() {
      _identifier = null;
      _batteryLevel = null;
      _deviceType = null;
      _hr = null;
      _isDeviceConnected = false;
      _plotPPGValues = List<SensorValue>.filled(
          _displayLength, SensorValue(null, null),
          growable: false);
      _plotACCValues = List<SensorValue>.filled(
          _displayLength, SensorValue(null, null),
          growable: false);
      _plotGyroValues = List<SensorValue>.filled(
          _displayLength, SensorValue(null, null),
          growable: false);
    });
  }

  void _streamWhenReady() async {
    print(polar.sdkFeatureReady.toString());
    await polar.sdkFeatureReady
        .firstWhere(
      (e) =>
          e.identifier == _identifier &&
          e.feature == PolarSdkFeature.onlineStreaming,
    )
        .timeout(Duration(seconds: 5), onTimeout: () {
      print('Timeout waiting for SDK feature to be ready');
      return PolarSdkFeatureReadyEvent(
          _identifier!, PolarSdkFeature.onlineStreaming);
    });

    final availabletypes =
        await polar.getAvailableOnlineStreamDataTypes(_identifier!);

    debugPrint('available types: $availabletypes');

    // Start streaming HR if available.
    if (availabletypes.contains(PolarDataType.hr)) {
      polar
          .startHrStreaming(_identifier!)
          .listen((e) => _hr = e.samples.last.hr);
    }

    // Start streaming PPG if available.
    if (availabletypes.contains(PolarDataType.ppg)) {
      polar.startPpgStreaming(_identifier!).listen((e) {
        setState(() {
          // channelSamples: one per color channel + one for ambient light
          for (var i = 0; i < e.samples.length; i++) {
            _plotPPGValues = _plotPPGValues.sublist(1)
              ..add(SensorValue(e.samples[i].timeStamp,
                  -e.samples[i].channelSamples[1].toDouble()));
            if (_isRecording) {
              _recordPPGValues.add(-e.samples[i].channelSamples[1]);
              _recordPPGTimestamps
                  .add(e.samples[i].timeStamp.millisecondsSinceEpoch);
            }
          }
        });
      });
    }

    // Start streaming ECG if available.
    if (availabletypes.contains(PolarDataType.ecg)) {
      polar.startEcgStreaming(_identifier!).listen((e) {
        setState(() {
          for (var i = 0; i < e.samples.length; i++) {
            _timestamps = _timestamps.sublist(1)..add(e.samples[i].timeStamp);
            _ECGValues = _ECGValues.sublist(1)..add(e.samples[i].voltage);
            _plotECGValues = _plotECGValues.sublist(1)
              ..add(SensorValue(
                  e.samples[i].timeStamp, e.samples[i].voltage.toDouble()));
            if (_isRecording) {
              _recordECGValues.add(e.samples[i].voltage);
              _recordECGTimestamps
                  .add(e.samples[i].timeStamp.millisecondsSinceEpoch);
            }
          }
          _filteredECGValues = filter(_ECGValues);
          _derivativeECGValues = derivative(_filteredECGValues);
          _squaredECGValues = square(_derivativeECGValues);
          _averagedECGValues = movingAverage(_squaredECGValues);
          _rpeaks = findRPeaks(_averagedECGValues);

          List<int> peaksECG = obtenerPeaksECGReales(
            _rpeaks,
            _recordECGTimestamps,
            _recordECGValues,
            400, // ventana de ±100ms
          );


          for (var i = 0; i < _filteredECGValues.length; i++) {
            _plotFilteredECGValues = _plotFilteredECGValues.sublist(1)
              ..add(SensorValue(_timestamps[i], _filteredECGValues[i]));
            _plotDerivativeECGValues = _plotDerivativeECGValues.sublist(1)
              ..add(SensorValue(_timestamps[i], _derivativeECGValues[i]));
            _plotSquaredECGValues = _plotSquaredECGValues.sublist(1)
              ..add(SensorValue(_timestamps[i], _squaredECGValues[i]));
            _plotAveragedECGValues = _plotAveragedECGValues.sublist(1)
              ..add(SensorValue(_timestamps[i], _averagedECGValues[i]));
            _plotRPeaks = _plotRPeaks.sublist(1)
              ..add(SensorValue(_timestamps[i],
                  _rpeaks.contains(i) ? _averagedECGValues[i] : 0));
          }
          List<int> rrIntervals = List<int>.generate(
              _rpeaks.length - 1, (i) => _rpeaks[i + 1] - _rpeaks[i]);
          double rrMean =
              rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
          double rrMeanSeconds = rrMean / 130;
          _hrFromECG = (60 / rrMeanSeconds).round();
          double rmssd = calcularRMSSD(rrIntervals);
          double sd1 = calcularSD1(rrIntervals);
          double sd2 = calcularSD1(rrIntervals);
          double dfa = calcularDFA(rrIntervals);

          print("RMSSD: $rmssd ms");
          print("SD1: $sd1 ms");
          print("SD2: $sd2 ms");
          print("DFA α: $dfa");

        });
      });
    }

    // Start streaming ACC if available.
    if (availabletypes.contains(PolarDataType.acc)) {
      polar.startAccStreaming(_identifier!).listen((e) {
        setState(() {
          for (var i = 0; i < e.samples.length; i++) {
            _plotACCValues = _plotACCValues.sublist(1)
              ..add(SensorValue(
                  e.samples[i].timeStamp,
                  sqrt(e.samples[i].x * e.samples[i].x +
                      e.samples[i].y * e.samples[i].y +
                      e.samples[i].z * e.samples[i].z)));
            if (_isRecording) {
              _recordACCValues
                  .add([e.samples[i].x, e.samples[i].y, e.samples[i].z]);
              _recordACCTimestamps
                  .add(e.samples[i].timeStamp.millisecondsSinceEpoch);
            }
          }
        });
      });
    }

    // Start streaming gyro if available.
    if (availabletypes.contains(PolarDataType.gyro)) {
      polar.startGyroStreaming(_identifier!).listen((e) {
        setState(() {
          for (var i = 0; i < e.samples.length; i++) {
            _plotGyroValues = _plotGyroValues.sublist(1)
              ..add(SensorValue(
                  e.samples[i].timeStamp,
                  sqrt(e.samples[i].x * e.samples[i].x +
                      e.samples[i].y * e.samples[i].y +
                      e.samples[i].z * e.samples[i].z)));
            if (_isRecording) {
              _recordGyroValues
                  .add([e.samples[i].x, e.samples[i].y, e.samples[i].z]);
              _recordGyroTimestamps
                  .add(e.samples[i].timeStamp.millisecondsSinceEpoch);
            }
          }
        });
      });
    }

    // Start streaming magnetometer if available.
    if (availabletypes.contains(PolarDataType.magnetometer)) {
      polar.startMagnetometerStreaming(_identifier!).listen((e) {
        setState(() {
          for (var i = 0; i < e.samples.length; i++) {
            _plotMagValues = _plotMagValues.sublist(1)
              ..add(SensorValue(
                  e.samples[i].timeStamp,
                  sqrt(e.samples[i].x * e.samples[i].x +
                      e.samples[i].y * e.samples[i].y +
                      e.samples[i].z * e.samples[i].z)));
            if (_isRecording) {
              _recordMagValues
                  .add([e.samples[i].x, e.samples[i].y, e.samples[i].z]);
              _recordMagTimestamps
                  .add(e.samples[i].timeStamp.millisecondsSinceEpoch);
            }
          }
        });
      });
    }
  }

  Future<void> _requestBluetoothPermission() async {
    if (await Permission.bluetooth.request().isGranted) {
      print("Bluetooth permission granted");
    } else {
      print("Bluetooth permission denied");
    }

    if (await Permission.bluetoothScan.request().isGranted) {
      print("Bluetooth scan permission granted");
    } else {
      print("Bluetooth scan permission denied");
    }

    if (await Permission.bluetoothConnect.request().isGranted) {
      print("Bluetooth connect permission granted");
    } else {
      print("Bluetooth connect permission denied");
    }
  }

  void _saveRecord() async {
    DateTime dt = DateTime.now();
    final directory = await getApplicationDocumentsDirectory();

    try {
      if (_deviceType == deviceType.H10) {
        String? filenameECG = sprintf(
            "%02i%02i%02i_h10_ecg.csv", [dt.hour, dt.minute, dt.second]);
        String? filenameACC = sprintf(
            "%02i%02i%02i_h10_acc.csv", [dt.hour, dt.minute, dt.second]);

        final pathECG = directory.path + "/" + filenameECG;
        final pathACC = directory.path + "/" + filenameACC;
        print(pathECG);
        print(pathACC);

        File fileECG = await File(pathECG).create();
        File fileACC = await File(pathACC).create();

        List<List<dynamic>> recordECG =
            List<List<dynamic>>.empty(growable: true);
        List<List<dynamic>> recordACC =
            List<List<dynamic>>.empty(growable: true);

        recordECG.add(["Timestamps", "Voltage"]);
        for (int i = 0; i < _recordECGValues.length; i++) {
          recordECG.add([_recordECGTimestamps[i], _recordECGValues[i]]);
        }

        recordACC.add(
            ["Timestamps", "AccelerationX", "AccelerationY", "AccelerationZ"]);
        for (int i = 0; i < _recordACCTimestamps.length; i++) {
          recordACC.add([
            _recordACCTimestamps[i],
            _recordACCValues[i][0],
            _recordACCValues[i][1],
            _recordACCValues[i][2]
          ]);
        }

        String csvECG = const ListToCsvConverter().convert(recordECG);
        String csvACC = const ListToCsvConverter().convert(recordACC);

        await fileECG.writeAsString(csvECG);
        await fileACC.writeAsString(csvACC);
        CustomToast.showToast("Saved locally");
      } else if (_deviceType == deviceType.Sense) {
        String? filenamePPG = sprintf(
            "%02i%02i%02i_sense_ppg.csv", [dt.hour, dt.minute, dt.second]);
        String? filenameACC = sprintf(
            "%02i%02i%02i_sense_acc.csv", [dt.hour, dt.minute, dt.second]);
        String? filenameGyro = sprintf(
            "%02i%02i%02i_sense_gyro.csv", [dt.hour, dt.minute, dt.second]);
        String? filenameMag = sprintf(
            "%02i%02i%02i_sense_mag.csv", [dt.hour, dt.minute, dt.second]);

        final pathPPG = directory.path + "/" + filenamePPG;
        final pathACC = directory.path + "/" + filenameACC;
        final pathGyro = directory.path + "/" + filenameGyro;
        final pathMag = directory.path + "/" + filenameMag;
        print(pathPPG);
        print(pathACC);
        print(pathGyro);
        print(pathMag);

        File filePPG = await File(pathPPG).create();
        File fileACC = await File(pathACC).create();
        File fileGyro = await File(pathGyro).create();
        File fileMag = await File(pathMag).create();

        List<List<dynamic>> recordPPG =
            List<List<dynamic>>.empty(growable: true);
        List<List<dynamic>> recordACC =
            List<List<dynamic>>.empty(growable: true);
        List<List<dynamic>> recordGyro =
            List<List<dynamic>>.empty(growable: true);
        List<List<dynamic>> recordMag =
            List<List<dynamic>>.empty(growable: true);

        recordPPG.add(["Timestamps", "PPG"]);
        for (int i = 0; i < _recordPPGValues.length; i++) {
          recordPPG.add([_recordPPGTimestamps[i], _recordPPGValues[i]]);
        }

        recordACC.add(
            ["Timestamps", "AccelerationX", "AccelerationY", "AccelerationZ"]);
        for (int i = 0; i < _recordACCTimestamps.length; i++) {
          recordACC.add([
            _recordACCTimestamps[i],
            _recordACCValues[i][0],
            _recordACCValues[i][1],
            _recordACCValues[i][2]
          ]);
        }

        recordGyro.add(["Timestamps", "GyroX", "GyroY", "GyroZ"]);
        for (int i = 0; i < _recordGyroValues.length; i++) {
          recordGyro.add([
            _recordGyroTimestamps[i],
            _recordGyroValues[i][0],
            _recordGyroValues[i][1],
            _recordGyroValues[i][2]
          ]);
        }

        recordMag.add(
            ["Timestamps", "MagnetometerX", "MagnetometerY", "MagnetometerZ"]);
        for (int i = 0; i < _recordMagValues.length; i++) {
          recordMag.add([
            _recordMagTimestamps[i],
            _recordMagValues[i][0],
            _recordMagValues[i][1],
            _recordMagValues[i][2]
          ]);
        }

        String csvPPG = const ListToCsvConverter().convert(recordPPG);
        String csvACC = const ListToCsvConverter().convert(recordACC);
        String csvGyro = const ListToCsvConverter().convert(recordGyro);
        String csvMag = const ListToCsvConverter().convert(recordMag);

        await filePPG.writeAsString(csvPPG);
        await fileACC.writeAsString(csvACC);
        await fileGyro.writeAsString(csvGyro);
        await fileMag.writeAsString(csvMag);

        CustomToast.showToast("Saved locally");
      } else {
        String? filenamePPG = sprintf(
            "%02i%02i%02i_oh1_ppg.csv", [dt.hour, dt.minute, dt.second]);
        String? filenameACC = sprintf(
            "%02i%02i%02i_oh1_acc.csv", [dt.hour, dt.minute, dt.second]);

        final pathPPG = directory.path + "/" + filenamePPG;
        final pathACC = directory.path + "/" + filenameACC;
        print(pathPPG);
        print(pathACC);

        File filePPG = await File(pathPPG).create();
        File fileACC = await File(pathACC).create();

        List<List<dynamic>> recordPPG =
            List<List<dynamic>>.empty(growable: true);
        List<List<dynamic>> recordACC =
            List<List<dynamic>>.empty(growable: true);

        recordPPG.add(["Timestamps", "PPG"]);
        for (int i = 0; i < _recordPPGValues.length; i++) {
          recordPPG.add([_recordPPGTimestamps[i], _recordPPGValues[i]]);
        }

        recordACC.add(
            ["Timestamps", "AccelerationX", "AccelerationY", "AccelerationZ"]);
        for (int i = 0; i < _recordACCTimestamps.length; i++) {
          recordACC.add([
            _recordACCTimestamps[i],
            _recordACCValues[i][0],
            _recordACCValues[i][1],
            _recordACCValues[i][2]
          ]);
        }

        String csvPPG = const ListToCsvConverter().convert(recordPPG);
        String csvACC = const ListToCsvConverter().convert(recordACC);

        await filePPG.writeAsString(csvPPG);
        await fileACC.writeAsString(csvACC);

        CustomToast.showToast("Saved locally");
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved!'))
);
      }
    } catch (e) {
      // Error saving local file
      CustomToast.showToast("Error saving file");
      print(e);
    }

    _recordPPGTimestamps.clear();
    _recordPPGValues.clear();
    _recordECGTimestamps.clear();
    _recordECGValues.clear();
    _recordACCValues.clear();
    _recordACCTimestamps.clear();
    _recordGyroValues.clear();
    _recordGyroTimestamps.clear();
    _recordMagValues.clear();
    _recordMagTimestamps.clear();
  }
}

enum deviceType {
  OH1,
  Sense,
  H10,
}
