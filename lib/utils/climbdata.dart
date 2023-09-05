import '../providers/climb_select_provider.dart';

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
};

enum routeType {
  basiconly,
  eventonly,
}

final Map<int, ClimbData> climbsData = {
  // 1: WorldData(
  //     1, GuestWorldId.watopia, 'Watopia', 'https://zwiftinsider.com/watopia/'),
  // 2: WorldData(2, GuestWorldId.richmond, 'Richmond',
  //     'https://zwiftinsider.com/richmond/'),
  // 3: WorldData(
  //     3, GuestWorldId.london, 'London', 'https://zwiftinsider.com/london/'),
  // 4: WorldData(4, GuestWorldId.newyork, 'NYC', 'https://zwiftinsider.com/nyc/'),
  // 5: WorldData(5, GuestWorldId.innsbruck, 'Innsbruck',
  //     'https://zwiftinsider.com/innsbruck/'),
  // 6: WorldData(6, GuestWorldId.bolognatt, 'Bologna TT',
  //     'https://zwiftinsider.com/innsbruck/'),
  // 7: WorldData(7, GuestWorldId.yorkshire, 'Yorkshire',
  //     'https://zwiftinsider.com/yorkshire/'),
  // 8: WorldData(8, GuestWorldId.critcity, 'Crit City',
  //     'https://zwiftinsider.com/yorkshire/'),
  // 10: WorldData(
  //     10, GuestWorldId.france, 'France', 'https://zwiftinsider.com/france/'),
  // 11: WorldData(
  //     11, GuestWorldId.paris, 'Paris', 'https://zwiftinsider.com/paris/'),
  // 12: WorldData(12, GuestWorldId.makuriislands, 'Makuri Islands',
  //     'https://zwiftinsider.com/makuri-islands/'),
  // 13: WorldData(13, GuestWorldId.scotland, 'Scotland',
  //     'https://zwiftinsider.com/scotland/')
};

// final Map<DateTime, List<int>> calendarModel = {
//   new DateTime(2020, 09, 01): [1, 10, 11],
//   new DateTime(2020, 09, 02): [1, 4, 2],
//   new DateTime(2020, 09, 03): [1, 4, 2],
//   new DateTime(2020, 09, 04): [1, 4, 2],
//   new DateTime(2020, 09, 05): [1, 4, 2],
//   new DateTime(2020, 09, 06): [1, 5, 2],
//   new DateTime(2020, 09, 07): [1, 5, 2],
//   new DateTime(2020, 09, 08): [1, 3, 7],
//   new DateTime(2020, 09, 09): [1, 3, 7],
//   new DateTime(2020, 09, 10): [1, 3, 7],
//   new DateTime(2020, 09, 11): [1, 2, 3],
//   new DateTime(2020, 09, 12): [1, 4, 2],
//   new DateTime(2020, 09, 13): [1, 4, 2],
//   new DateTime(2020, 09, 14): [1, 4, 2],
//   new DateTime(2020, 09, 15): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 16): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 17): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 18): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 19): [1, 3, 7],
//   new DateTime(2020, 09, 20): [1, 3, 7],
//   new DateTime(2020, 09, 21): [1, 3, 7],
//   new DateTime(2020, 09, 22): [1, 3, 7],
//   new DateTime(2020, 09, 23): [1, 4, 2],
//   new DateTime(2020, 09, 24): [1, 4, 2],
//   new DateTime(2020, 09, 25): [1, 7, 5],
//   new DateTime(2020, 09, 26): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 27): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 28): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 29): [
//     1,
//     10,
//     11,
//   ],
//   new DateTime(2020, 09, 30): [
//     1,
//     3,
//     7,
//   ],
//   // new DateTime(2020, 09, 31): [
//   //   1,
//   //   10,
//   // ]
// };

class World {}
