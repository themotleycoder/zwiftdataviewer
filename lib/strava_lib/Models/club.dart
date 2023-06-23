// Club

import 'fault.dart';

class Club {
  Fault? fault;
  int? id;
  int? resourceState;
  String? name;
  String? profileMedium;
  String? profile;
  String? coverPhoto;
  String? coverPhotoSmall;
  String? sportType;
  String? city;
  String? state;
  String? country;
  bool? private;
  int? memberCount;
  bool? featured;
  bool? verified;
  String? url;
  String? membership;
  bool? admin;
  bool? owner;
  String? description;
  String? clubType;
  int? postCount;
  int? ownerId;
  int? followingCount;

  Club(
      {Fault? fault,
      this.id,
      this.resourceState,
      this.name,
      this.profileMedium,
      this.profile,
      this.coverPhoto,
      this.coverPhotoSmall,
      this.sportType,
      this.city,
      this.state,
      this.country,
      this.private,
      this.memberCount,
      this.featured,
      this.verified,
      this.url,
      this.membership,
      this.admin,
      this.owner,
      this.description,
      this.clubType,
      this.postCount,
      this.ownerId,
      this.followingCount})
      : fault = Fault(88, '');

  Club.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name'];
    profileMedium = json['profile_medium'];
    profile = json['profile'];
    coverPhoto = json['cover_photo'];
    coverPhotoSmall = json['cover_photo_small'];
    sportType = json['sport_type'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    private = json['private'];
    memberCount = json['member_count'];
    featured = json['featured'];
    verified = json['verified'];
    url = json['url'];
    membership = json['membership'];
    admin = json['admin'];
    owner = json['owner'];
    description = json['description'];
    clubType = json['club_type'];
    postCount = json['post_count'];
    ownerId = json['owner_id'];
    followingCount = json['following_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['resource_state'] = resourceState;
    data['name'] = name;
    data['profile_medium'] = profileMedium;
    data['profile'] = profile;
    data['cover_photo'] = coverPhoto;
    data['cover_photo_small'] = coverPhotoSmall;
    data['sport_type'] = sportType;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['private'] = private;
    data['member_count'] = memberCount;
    data['featured'] = featured;
    data['verified'] = verified;
    data['url'] = url;
    data['membership'] = membership;
    data['admin'] = admin;
    data['owner'] = owner;
    data['description'] = description;
    data['club_type'] = clubType;
    data['post_count'] = postCount;
    data['owner_id'] = ownerId;
    data['following_count'] = followingCount;
    return data;
  }
}
