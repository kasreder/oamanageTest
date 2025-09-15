// lib/model/user.dart

/// 임직원 정보를 표현하는 모델
class User {
  final int no; // 오름차순 순번
  final String employeeId; // 고유 아이디 (B/P/A + 6자리 숫자)
  final String employeeName; // 이름
  final String? orgNameHq; // 본부
  final String? orgNameDept; // 실/부서
  final String? orgNameTeam; // 팀
  final String? orgNamePart; // 파트/업무
  final String? orgNameEtc; // 기타 직책
  final String? workLocationBuilding; // 근무 건물
  final String? workLocationFloor; // 근무 층

  const User({
    required this.no,
    required this.employeeId,
    required this.employeeName,
    this.orgNameHq,
    this.orgNameDept,
    this.orgNameTeam,
    this.orgNamePart,
    this.orgNameEtc,
    this.workLocationBuilding,
    this.workLocationFloor,
  });
}

/// 사원 이름 목록 (자산의 memberName과 연결)
const List<String> employeeNames = [
  '차두리',
  '강남길',
  '김유정',
  '김소연',
];

/// 조직명 목록들
const List<String?> orgNameHqList = [
  '개발본부',
  '영업본부',
  '기획본부',
  '운영본부',
  '마케팅본부',
  null,
];

const List<String?> orgNameDeptList = [
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

const List<String?> orgNameTeamList = [
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

const List<String?> orgNamePartList = [
  '콜업무',
  '추심업무',
  '제작업무',
  '영업업무',
  '고객응대업무',
  null,
];

const List<String?> orgNameEtcList = [
  '대표이사',
  '감사',
  '소비자보호',
  '고문',
  null,
];
