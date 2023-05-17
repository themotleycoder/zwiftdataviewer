// Detailed athlete
import 'fault.dart';

// NOT working yet, problem with club
// import 'club.dart';

class DetailedAthlete {
  Fault? fault;
  int? id;
  String? username;
  int? resourceState;
  String? firstname;
  String? lastname;
  String? city;
  String? state;
  String? country;
  String? sex;
  bool? premium;
  String? createdAt;
  String? updatedAt;
  int? badgeTypeId;
  String? profileMedium;
  String? profile;
  String? friend;
  String? follower;
  int? followerCount;
  int? friendCount;
  int? mutualFriendCount;
  int? athleteType;
  String? datePreference;
  String? measurementPreference;

  // List<Null> clubs;
  int? ftp;
  double? weight;
  List<Bikes>? bikes;
  List<Shoes>? shoes;

  DetailedAthlete(
      {Fault? fault,
      this.id,
      this.username,
      this.resourceState,
      this.firstname,
      this.lastname,
      this.city,
      this.state,
      this.country,
      this.sex,
      this.premium,
      this.createdAt,
      this.updatedAt,
      this.badgeTypeId,
      this.profileMedium,
      this.profile,
      this.friend,
      this.follower,
      this.followerCount,
      this.friendCount,
      this.mutualFriendCount,
      this.athleteType,
      this.datePreference,
      this.measurementPreference,
      // this.clubs,
      this.ftp,
      this.weight,
      this.bikes,
      this.shoes})
      : fault = Fault(99, '');

  DetailedAthlete.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    resourceState = json['resource_state'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    sex = json['sex'];
    premium = json['premium'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    badgeTypeId = json['badge_type_id'];
    profileMedium = json['profile_medium'];
    profile = json['profile'];
    friend = json['friend'];
    follower = json['follower'];
    followerCount = json['follower_count'];
    friendCount = json['friend_count'];
    mutualFriendCount = json['mutual_friend_count'];
    athleteType = json['athlete_type'];
    datePreference = json['date_preference'];
    measurementPreference = json['measurement_preference'];
    /****
        if (json['clubs'] != null) {
        clubs = List<Club>();
        json['clubs'].forEach((v) {
        clubs.add(Club.fromJson(v));
        });
        }
     ***/
    ftp = json['ftp'];
    weight = json['weight'];
    if (json['bikes'] != null) {
      bikes = <Bikes>[];
      json['bikes'].forEach((v) {
        bikes?.add(Bikes.fromJson(v));
      });
    }
    if (json['shoes'] != null) {
      shoes = <Shoes>[];
      json['shoes'].forEach((v) {
        shoes?.add(Shoes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['resource_state'] = resourceState;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['sex'] = sex;
    data['premium'] = premium;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['badge_type_id'] = badgeTypeId;
    data['profile_medium'] = profileMedium;
    data['profile'] = profile;
    data['friend'] = friend;
    data['follower'] = follower;
    data['follower_count'] = followerCount;
    data['friend_count'] = friendCount;
    data['mutual_friend_count'] = mutualFriendCount;
    data['athlete_type'] = athleteType;
    data['date_preference'] = datePreference;
    data['measurement_preference'] = measurementPreference;
    /***
        if (this.clubs != null) {
        data['clubs'] = this.clubs.map((v) => v.toJson()).toList();
        }
     ***/
    data['ftp'] = ftp;
    data['weight'] = weight;
    if (bikes != null) {
      data['bikes'] = bikes?.map((v) => v.toJson()).toList();
    }
    if (shoes != null) {
      data['shoes'] = shoes?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bikes {
  String? id;
  bool? primary;
  String? name;
  int? resourceState;
  double? distance;

  Bikes({this.id, this.primary, this.name, this.resourceState, this.distance});

  Bikes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    primary = json['primary'];
    name = json['name'];
    resourceState = json['resource_state'];
    distance = json['distance'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['primary'] = primary;
    data['name'] = name;
    data['resource_state'] = resourceState;
    data['distance'] = distance;
    return data;
  }
}

class Shoes {
  String? id;
  bool? primary;
  String? name;
  int? resourceState;
  double? distance;

  Shoes({this.id, this.primary, this.name, this.resourceState, this.distance});

  Shoes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    primary = json['primary'];
    name = json['name'];
    resourceState = json['resource_state'];
    distance = json['distance'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['primary'] = primary;
    data['name'] = name;
    data['resource_state'] = resourceState;
    data['distance'] = distance;
    return data;
  }
}
