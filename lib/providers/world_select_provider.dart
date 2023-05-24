import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/worlddata.dart';

class WorldSelectNotifier extends StateNotifier<WorldData> {
  WorldSelectNotifier()
      : super(WorldData(1, GuestWorldId.watopia, 'Watopia',
            'https://zwiftinsider.com/watopia/'));

  set worldSelect(WorldData worldSelect) {
    state = worldSelect;
  }

  WorldData get worldSelect => state;
}

final selectedWorldProvider =
    StateNotifierProvider<WorldSelectNotifier, WorldData>(
        (ref) => WorldSelectNotifier());

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
