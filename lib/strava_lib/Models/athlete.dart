class Athlete {
  int id;
  int resourceState;

  Athlete({required this.id, required this.resourceState});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      resourceState: json['resource_state'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['resource_state'] = resourceState;
    return data;
  }
}
