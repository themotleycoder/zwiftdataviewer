import 'package:zwiftdataviewer/utils/worldsconfig.dart';

class WorldData {
  int? id;
  GuestWorldId? guestWorldId;
  String? name;
  String? url;

  WorldData(this.id, this.guestWorldId, this.name, this.url);

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
