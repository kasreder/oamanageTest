// lib/model/building_pic.dart

/// 건물 · 층 · 도면 배경 파일 정보를 보관하는 간단한 모델
class BuildingPic {
  final String? buildingName; // 건물명 (없을 수 있음)
  final String floor;        // 층 (예: B1, F1)
  final String? bgFile;      // 배경 이미지 파일명

  const BuildingPic({this.buildingName, required this.floor, this.bgFile});
}

/// 사용 가능한 건물명 목록
const List<String?> buildingNames = [
  '콘코디언',
  '한경경제신문사',
  '본사',
  '센터',
  'CRM',
  null,
];

/// 사용 가능한 층 목록
const List<String> floorList = [
  'B7', 'B6', 'B5', 'B4', 'B3', 'B2', 'B1', 'L',
  'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10',
  'F11', 'F12', 'F13', 'F14', 'F15', 'F16', 'F17', 'F18', 'F19', 'F20', 'F21', 'F22',
];

/// 도면 배경 파일명 목록
const List<String?> buildingBgFiles = [
  'hankyung_16F_A.png',
  'conco_11F_A.jpg',
  null,
];
