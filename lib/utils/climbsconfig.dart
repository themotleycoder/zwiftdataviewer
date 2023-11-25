import 'package:zwiftdataviewer/models/climbdata.dart';

enum ClimbId {
  all,
  bealachnaba,
  coldaspin,
  coldelaMadone,
  coldesAravis,
  colduPlatzerwasel,
  colduTourmalet,
  colldOrdino,
  cotedeDomancy,
  cotedePike,
  cotedeTrebiac,
  crowRoad,
  laLagunaNegra,
  laSuperPlanchedesBellesFilles,
  oldLaHonda,
  oldWillungaHill,
  puydeDome,
  rocacorba,
  others
}

final Map<String, int> climbLookupByName = {
  'Bealach na Bà': 1,
  "Col d'Aspin": 2,
  'Col de la Madone': 3,
  'Col des Aravis': 4,
  'Col du Platzerwasel': 5,
  'Col du Tourmalet': 6,
  "Coll d'Ordino": 7,
  'Cote de Domancy': 8,
  'Cote de Pike': 9,
  'Cote de Trebiac': 10,
  'Crow Road': 11,
  'La Laguna Negra': 12,
  'La Super Planche des Belles Filles': 13,
  'Old La Honda': 14,
  'Old Willunga Hill': 15,
  'Puy de Dome': 16,
  'Rocacorba': 17,
};

enum climbType {
  basiconly,
  eventonly,
}

final Map<int, ClimbData> allClimbsConfig = {
  1: ClimbData(1, ClimbId.bealachnaba, 'Bealach na Bà',
      'https://zwiftinsider.com/portal/bealach-na-ba/'),
  2: ClimbData(2, ClimbId.coldaspin, "Col d'Aspin",
      'https://zwiftinsider.com/portal/col-daspin/'),
  3: ClimbData(3, ClimbId.coldelaMadone, 'Col de la Madone',
      'https://zwiftinsider.com/portal/col-de-la-madone/'),
  4: ClimbData(4, ClimbId.coldesAravis, 'Col des Aravis',
      'https://zwiftinsider.com/portal/col-des-aravis/'),
  5: ClimbData(5, ClimbId.colduPlatzerwasel, 'Col du Platzerwasel',
      'https://zwiftinsider.com/portal/col-du-platzerwasel/'),
  6: ClimbData(6, ClimbId.colduTourmalet, 'Col du Tourmalet',
      'https://zwiftinsider.com/portal/col-du-tourmalet/'),
  7: ClimbData(7, ClimbId.colldOrdino, "Coll d'Ordino",
      'https://zwiftinsider.com/portal/coll-dordino/'),
  8: ClimbData(8, ClimbId.cotedeDomancy, 'Cote de Domancy',
      'https://zwiftinsider.com/portal/cote-de-domancy/'),
  9: ClimbData(9, ClimbId.cotedePike, 'Cote de Pike',
      'https://zwiftinsider.com/portal/cote-de-pike/'),
  10: ClimbData(10, ClimbId.cotedeTrebiac, 'Cote de Trebiac',
      'https://zwiftinsider.com/portal/cote-de-trebiac/'),
  11: ClimbData(11, ClimbId.crowRoad, 'Crow Road',
      'https://zwiftinsider.com/portal/crow-road/'),
  12: ClimbData(12, ClimbId.laLagunaNegra, 'La Laguna Negra',
      'https://zwiftinsider.com/portal/la-laguna-negra/'),
  13: ClimbData(
      13,
      ClimbId.laSuperPlanchedesBellesFilles,
      'La Super Planche des Belles Filles',
      'https://zwiftinsider.com/portal/la-super-planche-des-belles-filles/'),
  14: ClimbData(14, ClimbId.oldLaHonda, 'Old La Honda',
      'https://zwiftinsider.com/portal/old-la-honda/'),
  15: ClimbData(15, ClimbId.oldWillungaHill, 'Old Willunga Hill',
      'https://zwiftinsider.com/portal/old-willunga-hill/'),
  16: ClimbData(16, ClimbId.puydeDome, 'Puy de Dome',
      'https://zwiftinsider.com/portal/puy-de-dome/'),
  17: ClimbData(17, ClimbId.rocacorba, 'Rocacorba',
      'https://zwiftinsider.com/portal/rocacorba/')
};

class Climb {}
