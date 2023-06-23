// zones
import 'fault.dart';

class Zone {
  Fault? fault;
  InfoZones? infoZones;

  Zone({this.fault, this.infoZones});

  factory Zone.fromJson(Map<String, dynamic> firstJson) {
    if (firstJson['heart_rate'] != null) {
      var parsedJson = firstJson['heart_rate'];
      var customZones = parsedJson['custom_zones'];
      var infoZones = InfoZones();
      var list = parsedJson['zones'] as List;
      var fault = Fault(99, '');
      List<DistributionBucket> distributionBucket =
          list.map((i) => DistributionBucket.fromJson(i)).toList();
      infoZones.customZones = customZones;
      infoZones.zones = distributionBucket;

      return Zone(
        fault: fault,
        infoZones: infoZones,
      );
    } else {
      Fault fault = Fault(99, '');
      return Zone(fault: fault, infoZones: null);
    }
  }
}

class InfoZones {
  bool? customZones;
  List<DistributionBucket>? zones;
}

class DistributionBucket {
  int? max;
  int? min;

  DistributionBucket({this.max, this.min});

  DistributionBucket.fromJson(Map<String, dynamic> json) {
    max = json['max'];
    min = json['min'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}
