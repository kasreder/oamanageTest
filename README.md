# oamanger

oamanger

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

정렬 단축키
Windows / Linux: Ctrl + Alt + L
macOS: Cmd + Option + L

## 프로젝트 구조

```text
oamanageTest/
├── lib/
│   ├── main.dart                  # 앱 진입점 및 라우팅 초기화
│   ├── model/                     # Asset/User/Drawing 등 도메인 모델 정의
│   ├── provider/                  # 상태 관리용 Provider 클래스
│   ├── repository/                # 메모리 시드 데이터 및 CRUD 로직
│   ├── route/                     # 라우트 이름과 네비게이션 설정
│   ├── seed/                      # 초기 샘플 데이터/격자 설정
│   ├── util/                      # 공통 유틸리티 함수 및 상수
│   └── view/                      # 화면 위젯 (자산 목록, 도면 배치 등)
├── assets/                        # (선택) 정적 리소스 배치 경로
├── test/                          # 위젯/단위 테스트
├── android, ios, macos, windows, linux, web/
│                                  # 각 플랫폼별 실행 설정
└── pubspec.yaml                   # Flutter 의존성과 에셋 정의
```

## DB 스키마 제안

현재 리포지토리는 메모리 기반 리포지토리를 사용하지만, 실제 운영 환경에서는 다음과 같은 관계형 데이터베이스 스키마를 적용할 수 있습니다.

### `users`
| 컬럼 | 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | 내부 식별자 |
| `employee_id` | TEXT | UNIQUE NOT NULL | B/P/A + 6자리 임직원 코드 |
| `employee_name` | TEXT | NOT NULL | 임직원 이름 |
| `organization_hq` | TEXT | NULL | 본부 이름 |
| `organization_dept` | TEXT | NULL | 실/부서 |
| `organization_team` | TEXT | NULL | 팀 |
| `organization_part` | TEXT | NULL | 파트 |
| `organization_etc` | TEXT | NULL | 기타 직책 |
| `work_building` | TEXT | NULL | 근무 건물 |
| `work_floor` | TEXT | NULL | 근무 층 |

### `assets`
| 컬럼 | 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | 내부 식별자 |
| `asset_uid` | TEXT | UNIQUE NOT NULL | 화면에 노출되는 자산 코드 (예: A01234) |
| `name` | TEXT | NOT NULL | 자산명 |
| `category` | TEXT | NOT NULL | 분류 (생산설비, IT장비 등) |
| `serial_number` | TEXT | NOT NULL | 시리얼 번호 |
| `model_name` | TEXT | NOT NULL | 모델명 |
| `vendor` | TEXT | NOT NULL | 공급/제조사 |
| `network` | TEXT | NULL | 네트워크 구분 |
| `physical_check_date` | DATETIME | NULL | 실사일 |
| `confirmation_date` | DATETIME | NULL | 확정일 |
| `normal_comment` | TEXT | NULL | 일반 비고 |
| `oa_comment` | TEXT | NULL | OA 비고 |
| `mac_address` | TEXT | NULL | MAC 주소 |
| `building` | TEXT | NULL | 설치 건물 |
| `floor` | TEXT | NULL | 설치 층 |
| `member_name` | TEXT | NULL | 담당자 이름 |
| `location_drawing_id` | INTEGER | NULL | `drawings.id` FK |
| `location_row` | INTEGER | NULL | 도면 격자 행 |
| `location_col` | INTEGER | NULL | 도면 격자 열 |
| `location_drawing_file` | TEXT | NULL | 배경 도면 파일명 |
| `created_at` | DATETIME | NOT NULL | 생성일 |
| `updated_at` | DATETIME | NOT NULL | 수정일 |

인덱스 예시: `CREATE INDEX idx_assets_member ON assets(member_name);`

### `drawings`
| 컬럼 | 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | 도면 고유 ID |
| `building` | TEXT | NOT NULL | 건물명 |
| `floor` | TEXT | NOT NULL | 층 |
| `title` | TEXT | NOT NULL | 도면 제목 |
| `note` | TEXT | NULL | 비고 |
| `image_name` | TEXT | NULL | 업로드된 원본 파일명 |
| `image_bytes` | BLOB | NULL | 도면 이미지 |
| `image_updated_at` | DATETIME | NULL | 이미지 업로드 시각 |
| `grid_rows` | INTEGER | NOT NULL DEFAULT 12 | 격자 행 |
| `grid_cols` | INTEGER | NOT NULL DEFAULT 18 | 격자 열 |
| `created_at` | DATETIME | NOT NULL | 생성일 |
| `updated_at` | DATETIME | NOT NULL | 수정일 |

### `drawing_cells`
| 컬럼 | 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| `drawing_id` | INTEGER | REFERENCES drawings(id) ON DELETE CASCADE | 도면 ID |
| `row` | INTEGER | NOT NULL | 격자 행 |
| `col` | INTEGER | NOT NULL | 격자 열 |
| `asset_id` | INTEGER | REFERENCES assets(id) ON DELETE CASCADE | 배치된 자산 |

복합 기본키: `PRIMARY KEY (drawing_id, row, col, asset_id)` 으로 다대다 관계를 표현합니다.

### `building_backgrounds`
| 컬럼 | 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | 내부 식별자 |
| `building_name` | TEXT | NULL | 건물 이름 (없을 수 있음) |
| `floor` | TEXT | NOT NULL | 층 |
| `background_file` | TEXT | NULL | 배경 이미지 파일명 |

해당 스키마를 사용하면 Flutter 애플리케이션에서 사용 중인 도메인 모델을 관계형 DB로 자연스럽게 매핑할 수 있으며, 자산-도면 간 위치 정보와 임직원 정보를 일관성 있게 관리할 수 있습니다.
