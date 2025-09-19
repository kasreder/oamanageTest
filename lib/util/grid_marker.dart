// lib/util/grid_marker.dart

import '../model/drawing.dart';

/// 셀 키 문자열을 (row, col) 튜플로 변환합니다. 잘못된 포맷이면 null.
(int, int)? parseCellKey(String key) {
  try {
    final rIdx = key.indexOf('r');
    final cIdx = key.indexOf('c');
    if (rIdx != 0 || cIdx < 0) return null;
    final row = int.parse(key.substring(1, cIdx));
    final col = int.parse(key.substring(cIdx + 1));
    return (row, col);
  } catch (_) {
    return null;
  }
}

/// 주어진 위치를 마커 크기에 맞춰 정규화한 (row, col)을 반환합니다.
/// - span 보다 작은 격자에서는 항상 (0,0)을 반환합니다.
(int, int) normalizeBlockOrigin({
  required int row,
  required int col,
  required int rows,
  required int cols,
  int span = Drawing.markerBlockSpan,
}) {
  int _normalizeIndex(int value, int maxCount) {
    if (maxCount <= span) {
      return 0;
    }
    final maxStart = maxCount - span;
    int clamped = value;
    if (clamped < 0) clamped = 0;
    if (clamped > maxStart) clamped = maxStart;
    return (clamped ~/ span) * span;
  }

  return (_normalizeIndex(row, rows), _normalizeIndex(col, cols));
}

/// (row, col) → `r{row}c{col}` 포맷의 셀 키로 변환합니다.
String cellKeyFrom({required int row, required int col}) => 'r${row}c$col';

/// 특정 위치에 마커를 배치할 수 있는지 검사합니다.
/// [row], [col]은 반드시 `normalizeBlockOrigin`을 거친 값이어야 합니다.
bool canPlaceMarker({
  required Map<String, List<String>> cellAssets,
  required int row,
  required int col,
  required int rows,
  required int cols,
  String? ignoreKey,
  int span = Drawing.markerBlockSpan,
}) {
  final targetKey = cellKeyFrom(row: row, col: col);

  String? ignoreNormalizedKey;
  if (ignoreKey != null) {
    final parsed = parseCellKey(ignoreKey);
    if (parsed != null) {
      final normalized = normalizeBlockOrigin(
        row: parsed.$1,
        col: parsed.$2,
        rows: rows,
        cols: cols,
        span: span,
      );
      ignoreNormalizedKey = cellKeyFrom(row: normalized.$1, col: normalized.$2);
    }
  }

  for (final entry in cellAssets.entries) {
    if (entry.value.isEmpty) continue;
    final parsed = parseCellKey(entry.key);
    if (parsed == null) continue;
    final normalized = normalizeBlockOrigin(
      row: parsed.$1,
      col: parsed.$2,
      rows: rows,
      cols: cols,
      span: span,
    );
    final otherKey = cellKeyFrom(row: normalized.$1, col: normalized.$2);
    if (otherKey == targetKey || (ignoreNormalizedKey != null && otherKey == ignoreNormalizedKey)) {
      continue; // 동일 위치 또는 무시 대상
    }

    final otherRow = normalized.$1;
    final otherCol = normalized.$2;
    final intersects = row < otherRow + span &&
        row + span > otherRow &&
        col < otherCol + span &&
        col + span > otherCol;
    if (intersects) {
      return false;
    }
  }
  return true;
}

/// 정규화된 위치에 포함된 자산 ID를 모두 수집합니다.
Set<String> collectAreaAssetIds({
  required Map<String, List<String>> cellAssets,
  required int row,
  required int col,
  required int rows,
  required int cols,
  int span = Drawing.markerBlockSpan,
}) {
  final normalized = normalizeBlockOrigin(
    row: row,
    col: col,
    rows: rows,
    cols: cols,
    span: span,
  );
  final targetKey = cellKeyFrom(row: normalized.$1, col: normalized.$2);

  final result = <String>{};
  for (final entry in cellAssets.entries) {
    if (entry.value.isEmpty) continue;
    final parsed = parseCellKey(entry.key);
    if (parsed == null) continue;
    final normalizedEntry = normalizeBlockOrigin(
      row: parsed.$1,
      col: parsed.$2,
      rows: rows,
      cols: cols,
      span: span,
    );
    final key = cellKeyFrom(row: normalizedEntry.$1, col: normalizedEntry.$2);
    if (key == targetKey) {
      result.addAll(entry.value);
    }
  }
  return result;
}

/// 격자 전체를 순회하며 정규화된 영역별 자산 ID 목록을 생성합니다.
Map<String, Set<String>> groupAssetsByArea({
  required Map<String, List<String>> cellAssets,
  required int rows,
  required int cols,
  int span = Drawing.markerBlockSpan,
}) {
  final grouped = <String, Set<String>>{};
  cellAssets.forEach((key, ids) {
    if (ids.isEmpty) return;
    final parsed = parseCellKey(key);
    if (parsed == null) return;
    final normalized = normalizeBlockOrigin(
      row: parsed.$1,
      col: parsed.$2,
      rows: rows,
      cols: cols,
      span: span,
    );
    final areaKey = cellKeyFrom(row: normalized.$1, col: normalized.$2);
    final areaSet = grouped.putIfAbsent(areaKey, () => <String>{});
    areaSet.addAll(ids);
  });
  return grouped;
}

/// 정규화된 영역과 실제 저장된 키를 매핑합니다.
Map<String, List<String>> mapAreaToOriginalKeys({
  required Map<String, List<String>> cellAssets,
  required int rows,
  required int cols,
  int span = Drawing.markerBlockSpan,
}) {
  final grouped = <String, List<String>>{};
  cellAssets.forEach((key, ids) {
    if (ids.isEmpty) return;
    final parsed = parseCellKey(key);
    if (parsed == null) return;
    final normalized = normalizeBlockOrigin(
      row: parsed.$1,
      col: parsed.$2,
      rows: rows,
      cols: cols,
      span: span,
    );
    final areaKey = cellKeyFrom(row: normalized.$1, col: normalized.$2);
    final list = grouped.putIfAbsent(areaKey, () => <String>[]);
    list.add(key);
  });
  return grouped;
}

