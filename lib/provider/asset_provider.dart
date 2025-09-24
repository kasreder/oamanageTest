// lib/provider/asset_provider.dart
import 'package:flutter/material.dart';
import '../model/asset.dart';
import '../repository/asset_repository.dart';
import '../util/grid_marker.dart';
import 'drawing_provider.dart'; // 도면에 반영하기 위해 사용

class AssetProvider extends ChangeNotifier {
  final AssetRepository repo = AssetRepository();

  List<Asset> items = [];

  AssetProvider() {
    items = repo.list();
  }

  Asset? getById(String id) => repo.getById(id);

  Asset? getByCode(String code) => repo.getByCode(code);

  void reload() {
    items = repo.list();
    notifyListeners();
  }

  Asset createAsset({
    required String code,
    required String name,
    required String category,
    required String serialNumber,
    required String modelName,
    required String vendor,
    String? network,
    String? normalComment,
    String? oaComment,
    String? macAddress,
    String? building,
    String? floor,
    String? memberName,
  }) {
    final asset = repo.createFromSchema(
      code: code,
      name: name,
      category: category,
      serialNumber: serialNumber,
      modelName: modelName,
      vendor: vendor,
      network: network,
      normalComment: normalComment,
      oaComment: oaComment,
      macAddress: macAddress,
      building: building,
      floor: floor,
      memberName: memberName,
    );
    items = repo.list();
    notifyListeners();
    return asset;
  }

  Asset? updateAsset(Asset asset) {
    final updated = repo.update(asset);
    items = repo.list();
    notifyListeners();
    return updated;
  }

  // 자산 위치 변경 + 도면 셀에 동기화
  Future<Asset?> setLocationAndSync({
    required String assetId,
    required String? drawingId, // null이면 위치 해제
    int? row,
    int? col,
    String? drawingFile,
    required DrawingProvider drawingProvider,
  }) async {
    // 기존 위치(제거 목적)
    final before = repo.getById(assetId);

    int? normalizedRow = row;
    int? normalizedCol = col;
    if (drawingId != null && row != null && col != null) {
      final drawing = drawingProvider.getById(drawingId);
      if (drawing != null) {
        final normalized = normalizeBlockOrigin(
          row: row,
          col: col,
          rows: drawing.gridRows,
          cols: drawing.gridCols,
        );
        normalizedRow = normalized.$1;
        normalizedCol = normalized.$2;

        String? ignoreKey;
        if (before != null &&
            before.locationDrawingId == drawingId &&
            before.locationRow != null &&
            before.locationCol != null) {
          ignoreKey = cellKeyFrom(row: before.locationRow!, col: before.locationCol!);
        }

        final canPlace = canPlaceMarker(
          cellAssets: drawing.cellAssets,
          row: normalizedRow!,
          col: normalizedCol!,
          rows: drawing.gridRows,
          cols: drawing.gridCols,
          ignoreKey: ignoreKey,
        );
        if (!canPlace) {
          throw StateError('marker_overlap');
        }
      }
    }

    // 자산 위치 저장
    final updated = repo.setLocation(
      id: assetId,
      drawingId: drawingId,
      row: normalizedRow,
      col: normalizedCol,
      drawingFile: drawingFile ?? (drawingId == null ? null : before?.locationDrawingFile),
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
      if (normalizedRow != null && normalizedCol != null) {
        await drawingProvider.addAssetToCell(
          id: updated.locationDrawingId!,
          row: normalizedRow!,
          col: normalizedCol!,
          assetId: assetId,
        );
      }
    }

    return updated;
  }
}
