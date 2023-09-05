import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/climbdata.dart';

class ClimbSelectNotifier extends StateNotifier<ClimbData> {
  ClimbSelectNotifier()
      : super(ClimbData(1, GuestWorldId.watopia, 'Watopia',
            'https://zwiftinsider.com/watopia/'));

  set worldSelect(ClimbData climbSelect) {
    state = worldSelect;
  }

  ClimbData get worldSelect => state;
}

final selectedClimbProvider =
    StateNotifierProvider<ClimbSelectNotifier, ClimbData>(
        (ref) => ClimbSelectNotifier());

class ClimbData {
  int? id;
  GuestWorldId? guestWorldId;
  String? name;
  String? url;

  ClimbData(this.id, this.guestWorldId, this.name, this.url);

  ClimbData.fromJson(Map<String, dynamic> json) {
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
