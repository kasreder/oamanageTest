// lib/seed/grid_seed.dart
/// 격자/도면 공통 설정 시드값 (여기만 바꾸면 앱 전체 반영)
class GridSeed {
  /// ✅ 행/열 기본값 (새 도면 생성 시 사용)
  static const int defaultRows = 60;
  static const int defaultCols = 120;

  /// ✅ 그리드 모드
  /// - true  : "비례 모드" (행/열 고정, 화면/이미지 크기에 맞춰 셀 픽셀 크기만 변함)
  /// - false : "고정 셀 모드" (cellSizePx 픽셀 단위로 칸을 나눔; 행/열은 화면/이미지에 따라 변동)
  ///   ※ 자산 배치를 (r,c)로 고정하려면 `useProportionalGrid = true` 권장
  static const bool useProportionalGrid = true;

  /// ✅ 고정 셀 모드에서 사용할 셀 크기(px). (useProportionalGrid=false일 때만 의미 있음)
  static const double cellSizePx = 5000.0;

  /// ✅ 격자선/테두리 색상 및 두께
  static const int gridColorHex   = 0x38000000; // 검정
  static const int borderColorHex = 0xFF000000; // 검정
  static const double gridStrokeWidth   = 0.5;
  static const double borderStrokeWidth = 2.0;

  /// ✅ 이미지 최대 표시 크기(상한). (보통은 이미지 원본 비율로 화면에 맞춰 스케일)
  static const double maxCanvasW = 1920.0;
  static const double maxCanvasH = 1080.0;

  /// ✅ 행/열 입력 허용 범위(가드)
  static const int minRows = 1;
  static const int minCols = 1;
  static const int maxRows = 1000000;
  static const int maxCols = 1000000;
}
