// gear.dart

import 'fault.dart';

class Gear {
  Fault? fault;
  String? id;
  bool? primary;
  int? resourceState;
  int? distance;
  String? brandName;
  String? modelName;
  int? frameType;
  String? description;

  Gear(
      {Fault? fault,
      this.id,
      this.primary,
      this.resourceState,
      this.distance,
      this.brandName,
      this.modelName,
      this.frameType,
      this.description})
      : fault = Fault(88, '');

  Gear.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    primary = json['primary'];
    resourceState = json['resource_state'];
    distance = json['distance'];
    brandName = json['brand_name'];
    modelName = json['model_name'];
    frameType = json['frame_type'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['primary'] = primary;
    data['resource_state'] = resourceState;
    data['distance'] = distance;
    data['brand_name'] = brandName;
    data['model_name'] = modelName;
    data['frame_type'] = frameType;
    data['description'] = description;
    return data;
  }
}
