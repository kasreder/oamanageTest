// lib/provider/drawing_provider.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/drawing.dart';
import '../repository/drawing_repository.dart';

class DrawingProvider extends ChangeNotifier {
  final DrawingRepository repo = DrawingRepository();

  // 목록 상태
  String keyword = '';
  String? building;
  String? floor;
  String sort = 'updatedAt_desc';
  int page = 1;
  final int pageSize = 12;

  List<Drawing> items = [];
  int totalCount = 0;

  final List<String> buildings = ['전체', 'HQ', 'R&D', 'Factory'];
  final List<String> floors = ['전체', 'B1', '1F', '2F', '3F'];

  DrawingProvider() {
    fetchList();
  }

  Future<void> fetchList() async {
    items = repo.list(
      keyword: keyword,
      building: (building == null || building == '전체') ? null : building,
      floor: (floor == null || floor == '전체') ? null : floor,
      sort: sort,
      page: page,
      pageSize: pageSize,
    );
    totalCount = repo.count(
      keyword: keyword,
      building: (building == null || building == '전체') ? null : building,
      floor: (floor == null || floor == '전체') ? null : floor,
    );
    notifyListeners();
  }

  Future<void> search(String k) async { keyword = k; page = 1; await fetchList(); }
  Future<void> changeBuilding(String? v) async { building = v ?? '전체'; page = 1; await fetchList(); }
  Future<void> changeFloor(String? v) async { floor = v ?? '전체'; page = 1; await fetchList(); }
  Future<void> changeSort(String s) async { sort = s; page = 1; await fetchList(); }
  Future<void> goPage(int p) async { page = p; await fetchList(); }

  Drawing? getById(String id) => repo.getById(id);

  Future<Drawing> create({
    required String building,
    required String floor,
    required String title,
    String? note,
  }) async {
    final now = DateTime.now();
    final d = Drawing(
      id: 'D${DateTime.now().millisecondsSinceEpoch}',
      building: building,
      floor: floor,
      title: title,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    repo.create(d);
    await fetchList();
    return d;
  }

  Future<bool> remove(String id) async {
    final ok = repo.delete(id);
    await fetchList();
    return ok;
  }

  /// 파일 선택/업로드 등에서 이미지 붙일 때 사용
  Future<Drawing?> attachImage({
    required String id,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final updated = repo.updateImage(id: id, bytes: bytes, fileName: fileName);
    await fetchList();
    return updated;
  }

  /// ✅ drawing_screen.dart 의 "열기" 흐름에서 호출하는 메서드
  /// - 파일명 없이 바이트만 넘어와도 동작하도록 기본 파일명을 넣어줌
  Future<Drawing?> setImageBytes({
    required String id,
    required Uint8List bytes,
    String? fileName,
  }) async {
    final updated = repo.updateImage(
      id: id,
      bytes: bytes,
      fileName: fileName ?? 'asset://applied_from_memory', // 기본값
    );
    await fetchList();
    return updated;
  }

  Future<Drawing?> setGrid({
    required String id,
    required int rows,
    required int cols,
  }) async {
    final updated = repo.setGrid(id: id, rows: rows, cols: cols);
    await fetchList();
    return updated;
  }

  Future<Drawing?> addAssetToCell({
    required String id,
    required int row,
    required int col,
    required String assetId,
  }) async {
    final updated = repo.addAssetToCell(id: id, row: row, col: col, assetId: assetId);
    await fetchList();
    return updated;
  }

  Future<Drawing?> removeAssetFromCell({
    required String id,
    required int row,
    required int col,
    required String assetId,
  }) async {
    final updated = repo.removeAssetFromCell(id: id, row: row, col: col, assetId: assetId);
    await fetchList();
    return updated;
  }

  List<String> allAssetIds(String id) => repo.allAssetIds(id);
}
