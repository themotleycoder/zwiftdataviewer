import 'package:zwiftdataviewer/utils/climbsconfig.dart';

class ClimbData {
  int? id;
  ClimbId? climbId;
  String? name;
  String? url;

  ClimbData(this.id, this.climbId, this.name, this.url);

  ClimbData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    climbId = json['climbId'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['climbId'] = climbId.toString();
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
