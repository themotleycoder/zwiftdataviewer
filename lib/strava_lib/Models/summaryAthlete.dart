// Summary Athlete

import 'fault.dart';

class SummaryAthlete {
  Fault? fault;
  int? resourceState;
  String? firstname;
  String? lastname;
  String? membership;
  bool? admin;
  bool? owner;
  int? id;

  SummaryAthlete(
      {this.fault,
      this.resourceState,
      this.firstname,
      this.lastname,
      this.membership,
      this.admin,
      this.owner,
      this.id});

  SummaryAthlete.fromJson(Map<String, dynamic> json) {
    resourceState = json['resource_state'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    membership = json['membership'];
    admin = json['admin'];
    owner = json['owner'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_state'] = resourceState;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['membership'] = membership;
    data['admin'] = admin;
    data['owner'] = owner;
    data['id'] = id;
    return data;
  }
}
