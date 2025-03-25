import 'package:zwiftdataviewer/models/worlddata.dart';

enum GuestWorldId {
  all,
  london,
  yorkshire,
  innsbruck,
  richmond,
  newyork,
  france,
  paris,
  watopia,
  critcity,
  bolognatt,
  makuriislands,
  scotland,
  gravelmountain,
  others
}

final Map<String, int> worldLookupByName = {
  'Watopia': 1,
  'Richmond': 2,
  'London': 3,
  'New York': 4,
  'Innsbruck': 5,
  'Bologna': 6,
  'Yorkshire': 7,
  'Crit City': 8,
  'France': 10,
  'Paris': 11,
  'Makuri Islands': 12,
  'Scotland': 13,
  'Gravel Mountain': 14,
};

enum routeType {
  basiconly,
  eventonly,
}

final Map<int, WorldData> allWorldsConfig = {
  1: const WorldData(
      1, GuestWorldId.watopia, 'Watopia', 'https://zwiftinsider.com/watopia/'),
  2: const WorldData(2, GuestWorldId.richmond, 'Richmond',
      'https://zwiftinsider.com/richmond/'),
  3: const WorldData(
      3, GuestWorldId.london, 'London', 'https://zwiftinsider.com/london/'),
  4: const WorldData(
      4, GuestWorldId.newyork, 'NYC', 'https://zwiftinsider.com/nyc/'),
  5: const WorldData(5, GuestWorldId.innsbruck, 'Innsbruck',
      'https://zwiftinsider.com/innsbruck/'),
  6: const WorldData(6, GuestWorldId.bolognatt, 'Bologna TT',
      'https://zwiftinsider.com/innsbruck/'),
  7: const WorldData(7, GuestWorldId.yorkshire, 'Yorkshire',
      'https://zwiftinsider.com/yorkshire/'),
  8: const WorldData(8, GuestWorldId.critcity, 'Crit City',
      'https://zwiftinsider.com/yorkshire/'),
  10: const WorldData(
      10, GuestWorldId.france, 'France', 'https://zwiftinsider.com/france/'),
  11: const WorldData(
      11, GuestWorldId.paris, 'Paris', 'https://zwiftinsider.com/paris/'),
  12: const WorldData(12, GuestWorldId.makuriislands, 'Makuri Islands',
      'https://zwiftinsider.com/makuri-islands/'),
  13: const WorldData(13, GuestWorldId.scotland, 'Scotland',
      'https://zwiftinsider.com/scotland/'),
  14: const WorldData(14, GuestWorldId.gravelmountain, 'Gravel Mountain',
      'https://zwiftinsider.com/gravel-mountain/')
};

class World {}
