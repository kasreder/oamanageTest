// lib/model/user.dart

import 'dart:math';

class User {
  final String no; // 오름차순 순번
  final String employeeId; // B/P/A + 6 digits
  final String employeeName; // 연예인 이름
  final String? organizationNameHQ;
  final String? organizationNameDept;
  final String? organizationNameTeam;
  final String? organizationNamePart;
  final String? organizationNameEtc;
  final String? workBuilding; // building name
  final String? workFloor; // floor

  const User({
    required this.no,
    required this.employeeId,
    required this.employeeName,
    this.organizationNameHQ,
    this.organizationNameDept,
    this.organizationNameTeam,
    this.organizationNamePart,
    this.organizationNameEtc,
    this.workBuilding,
    this.workFloor,
  });
}

// 샘플 연예인 이름 (asset.memberName과 연결)
const List<String> kEmployeeNames = ['아이유', '차은우', '손예진', '박보검'];

// 조직명 목록
const List<String?> kOrganizationNameHQ = [
  '개발본부',
  '영업본부',
  '기획본부',
  '운영본부',
  '마케팅본부',
  null,
];

const List<String?> kOrganizationNameDept = [
  '개발1실',
  '개발2실',
  '영업1실',
  '영업2실',
  '기획1실',
  '기획2실',
  '운영1실',
  '운영2실',
  '마케팅1실',
  '마케팅2실',
  null,
];

const List<String?> kOrganizationNameTeam = [
  '프론트개발팀',
  '백엔드개발팀',
  '해외영업팀',
  '국내영업팀',
  '구매기획팀',
  '운영기획팀',
  'IT운영1팀',
  'IT운영2팀',
  '직작인마케팅팀',
  '학생마케팅팀',
  '음악인마케팅팀',
  '은퇴자마케팅팀',
  null,
];

const List<String?> kOrganizationNamePart = [
  '콜업무',
  '추심업무',
  '제작업무',
  '영업업무',
  '고객응대업무',
  null,
];

const List<String?> kOrganizationNameEtc = [
  '대표이사',
  '감사',
  '소비자보호',
  '고문',
  null,
];

// 임직원 ID 생성기
String generateEmployeeId(Random rnd) {
  const prefixes = ['B', 'P', 'A'];
  final prefix = prefixes[rnd.nextInt(prefixes.length)];
  final numPart = rnd.nextInt(1000000).toString().padLeft(6, '0');
  return '$prefix$numPart';
}
