import 'package:zwiftdataviewer/models/calendardata.dart';
import 'package:zwiftdataviewer/utils/climbdata.dart';

class ClimbData extends CalendarData {
  ClimbId? climbId;
  String? name;
  String? url;

  ClimbData(int id, this.climbId, this.name, this.url){
    super.id = id;
  }

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