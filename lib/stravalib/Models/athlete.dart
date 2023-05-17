class Athlete {
  int? id;
  int? resourceState;

  Athlete({this.id, this.resourceState});

  Athlete.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['resource_state'] = resourceState;
    return data;
  }
}
