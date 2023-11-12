import 'package:zwiftdataviewer/models/calendardata.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

class WorldData extends CalendarData {
  GuestWorldId? guestWorldId;
  String? name;
  String? url;

  WorldData(int id, this.guestWorldId, this.name, this.url){
    super.id = id;
  }

  WorldData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // guestWorldId = json['guestWorldId'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['guestWorldId'] = guestWorldId.toString();
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}