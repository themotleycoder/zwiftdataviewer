class RouteData {
  String? url;
  String? world;
  double? distanceMeters;
  double? altitudeMeters;
  String? eventOnly;
  String? routeName;
  bool? completed = false;
  int? id;
  int? imageId;

  RouteData(this.url, this.world, this.distanceMeters, this.altitudeMeters,
      this.eventOnly, this.routeName, this.id);

  RouteData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    world = json['world'];
    distanceMeters = json['distanceMeters'];
    altitudeMeters = json['altitudeMeters'];
    eventOnly = json['eventOnly'];
    routeName = json['routeName'];
    completed = json['completed'];
    id = json['id'];
    imageId = json['imageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['world'] = world;
    data['distanceMeters'] = distanceMeters;
    data['altitudeMeters'] = altitudeMeters;
    data['eventOnly'] = eventOnly;
    data['routeName'] = routeName;
    data['completed'] = completed;
    data['id'] = id;
    data['imageId'] = imageId;
    return data;
  }
}
