// lib/provider/asset_provider.dart
import 'package:flutter/material.dart';
import '../model/asset.dart';
import '../repository/asset_repository.dart';
import 'drawing_provider.dart'; // 도면에 반영하기 위해 사용

class AssetProvider extends ChangeNotifier {
  final AssetRepository repo = AssetRepository();

  List<Asset> items = [];

  AssetProvider() {
    items = repo.list();
  }

  Asset? getById(String id) => repo.getById(id);

  void reload() {
    items = repo.list();
    notifyListeners();
  }

  // 자산 위치 변경 + 도면 셀에 동기화
  Future<Asset?> setLocationAndSync({
    required String assetId,
    required String? drawingId, // null이면 위치 해제
    int? row,
    int? col,
    required DrawingProvider drawingProvider,
  }) async {
    // 기존 위치(제거 목적)
    final before = repo.getById(assetId);

    // 자산 위치 저장
    final updated = repo.setLocation(
      id: assetId,
      drawingId: drawingId,
      row: row,
      col: col,
    );
    items = repo.list();
    notifyListeners();

    // 도면 반영: 이전 위치 제거
    if (before != null && before.locationDrawingId != null) {
      await drawingProvider.removeAssetFromCell(
        id: before.locationDrawingId!,
        row: before.locationRow ?? 0,
        col: before.locationCol ?? 0,
        assetId: assetId,
      );
    }

    // 도면 반영: 새 위치 추가
    if (updated != null && updated.locationDrawingId != null) {
      await drawingProvider.addAssetToCell(
        id: updated.locationDrawingId!,
        row: updated.locationRow ?? 0,
        col: updated.locationCol ?? 0,
        assetId: assetId,
      );
    }

    return updated;
  }
}
