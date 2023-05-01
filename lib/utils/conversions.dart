import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';

class Conversions {
  static double metersToDistance(BuildContext context, double meters) {
    final bool? isMetric = Provider.of<ConfigDataModel>(context, listen: false)
        .configData
        ?.isMetric;
    if (isMetric != null && isMetric) {
      return (meters * 0.001);
    } else {
      return (meters * 0.000621);
    }
  }

  static double metersToHeight(BuildContext context, double meters) {
    final bool? isMetric = Provider.of<ConfigDataModel>(context, listen: false)
        .configData
        ?.isMetric;
    if (isMetric != null && isMetric) {
      return meters;
    } else {
      return (meters * 3.2808);
    }
  }

  static String secondsToTime(int seconds) {
    int hours = (seconds ~/ 3600) % 24;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  static double mpsToMph(double mps) {
    return (mps * 2.237);
  }

  static Map<String, String> units(BuildContext context) {
    final bool? isMetric = Provider.of<ConfigDataModel>(context, listen: false)
        .configData
        ?.isMetric;

    if (isMetric != null && isMetric) {
      return {'distance': 'km', 'height': 'm', 'speed': 'kph'};
    } else {
      return {'distance': 'mi', 'height': 'ft', 'speed': 'mph'};
    }
  }
}
