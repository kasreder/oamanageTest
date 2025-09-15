// lib/model/buildingPic.dart

class BuildingPic {
  final String? buildingName;
  final String floor;
  final String? buildingBgFile;

  const BuildingPic({
    required this.buildingName,
    required this.floor,
    this.buildingBgFile,
  });
}

const List<String?> kBuildingNames = [
  '콘코디언',
  '한경경제신문사',
  '본사',
  '센터',
  'CRM',
  null,
];

final List<String> kFloors = [
  'B7',
  'B6',
  'B5',
  'B4',
  'B3',
  'B2',
  'B1',
  'L',
  for (var i = 1; i <= 22; i++) 'F$i',
];

const List<String?> kBuildingBgFiles = [
  'hankyung_16F_A.png',
  'conco_11F_A.jpg',
  null,
];
