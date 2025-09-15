// lib/repository/drawing_repository.dart
import 'dart:typed_data';
import '../model/drawing.dart';
import '../seed/grid_seed.dart';

class DrawingRepository {
  final List<Drawing> _items = [];

  DrawingRepository() {
    final now = DateTime.now();
    final List<(String, String, String, String?)> seeds = [
      ('HQ',      '1F', 'HQ 1층 공용구역',   null),
      ('HQ',      '2F', 'HQ 2층 사무실',     '좌측 구역은 미사용'),
      ('R&D',     'B1', 'R&D 지하 설비실',   null),
      ('R&D',     '3F', 'R&D 3층 테스트랩',  '고전압 주의'),
      ('Factory', '1F', '생산동 1층',        null),
      ('Factory', '2F', '생산동 2층',        '라인 B 공사중'),
      ('Office', '11F', 'conco',        '사무공간'),
      ('Office', '16F', 'hankyung',        '사무공간'),
    ];
    int i = 1;
    for (final s in seeds) {
      _items.add(
        Drawing(
          id: 'D$i',
          building: s.$1,
          floor: s.$2,
          title: s.$3,
          note: s.$4,
          imageBytes: null,
          imageName: null,
          imageUpdatedAt: null,
          gridRows: GridSeed.defaultRows, // ✅ seed에서 값 가져오기
          gridCols: GridSeed.defaultCols, // ✅ seed에서 값 가져오기
          createdAt: now.subtract(Duration(days: 20 - i)),
          updatedAt: now.subtract(Duration(days: 20 - i)),
        ),
      );
      i++;
    }
  }

  List<Drawing> list({
    String? keyword,
    String? building,
    String? floor,
    String sort = 'updatedAt_desc',
    int page = 1,
    int pageSize = 12,
  }) {
    Iterable<Drawing> data = _items;

    if (keyword != null && keyword.trim().isNotEmpty) {
      final k = keyword.trim().toLowerCase();
      data = data.where((e) =>
      e.title.toLowerCase().contains(k) ||
          e.building.toLowerCase().contains(k) ||
          e.floor.toLowerCase().contains(k));
    }
    if (building != null && building.isNotEmpty) {
      data = data.where((e) => e.building == building);
    }
    if (floor != null && floor.isNotEmpty) {
      data = data.where((e) => e.floor == floor);
    }

    switch (sort) {
      case 'title_asc':
        data = data.toList()..sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        data = data.toList()..sort((a, b) => b.title.compareTo(a.title));
        break;
      default:
        data = data.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final list = data.toList();
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  int count({String? keyword, String? building, String? floor}) {
    return list(keyword: keyword, building: building, floor: floor, page: 1, pageSize: 999999).length;
  }

  Drawing? getById(String id) => _items.where((e) => e.id == id).firstOrNull;

  Drawing create(Drawing drawing) {
    _items.insert(0, drawing);
    return drawing;
  }

  // 배경 도면 이미지 저장/갱신
  Drawing? updateImage({
    required String id,
    required Uint8List bytes,
    required String fileName,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final now = DateTime.now();
    _items[idx] = _items[idx].copyWith(
      imageBytes: bytes,
      imageName: fileName,
      imageUpdatedAt: now,
      updatedAt: now,
    );
    return _items[idx];
  }

  // 격자 크기 변경
  Drawing? setGrid({
    required String id,
    required int rows,
    required int cols,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final now = DateTime.now();
    final current = _items[idx];
    _items[idx] = current.copyWith(
      gridRows: rows,
      gridCols: cols,
      updatedAt: now,
    );
    return _items[idx];
  }

  // 칸 키
  String cellKey(int r, int c) => 'r${r}c$c';

  // 칸에 자산 추가
  Drawing? addAssetToCell({
    required String id,
    required int row,
    required int col,
    required String assetId,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final now = DateTime.now();
    final d = _items[idx];
    final key = cellKey(row, col);
    final map = Map<String, List<String>>.from(d.cellAssets);
    final list = List<String>.from(map[key] ?? const []);
    if (!list.contains(assetId)) list.add(assetId);
    map[key] = list;
    _items[idx] = d.copyWith(cellAssets: map, updatedAt: now);
    return _items[idx];
  }

  // 칸에서 자산 제거
  Drawing? removeAssetFromCell({
    required String id,
    required int row,
    required int col,
    required String assetId,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final now = DateTime.now();
    final d = _items[idx];
    final key = cellKey(row, col);
    final map = Map<String, List<String>>.from(d.cellAssets);
    final list = List<String>.from(map[key] ?? const []);
    list.remove(assetId);
    if (list.isEmpty) {
      map.remove(key);
    } else {
      map[key] = list;
    }
    _items[idx] = d.copyWith(cellAssets: map, updatedAt: now);
    return _items[idx];
  }

  // 도면 전체 자산 ID 목록
  List<String> allAssetIds(String id) {
    final d = getById(id);
    if (d == null) return [];
    return d.cellAssets.values.expand((e) => e).toSet().toList();
  }

  bool delete(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return _items.length < before;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
