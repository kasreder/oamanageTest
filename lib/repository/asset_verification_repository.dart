import '../model/asset_verification.dart';

class AssetVerificationRepository {
  final List<AssetVerification> _items = [];
  int _idCounter = 0;

  List<AssetVerification> list() => List.unmodifiable(_items);

  AssetVerification? getByAssetId(String assetId) =>
      _items.where((e) => e.assetId == assetId).firstOrNull;

  AssetVerification save({
    required String assetId,
    required String assetNumber,
    required String ownerName,
    required String serialNumber,
    required String assetCategory,
    required String usageType,
    required String modelName,
    required String team,
    required String building,
    required String floor,
    required String networkType,
    required String usageDetail,
    required String signature,
  }) {
    final now = DateTime.now();
    final idx = _items.indexWhere((element) => element.assetId == assetId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        assetNumber: assetNumber,
        ownerName: ownerName,
        serialNumber: serialNumber,
        assetCategory: assetCategory,
        usageType: usageType,
        modelName: modelName,
        team: team,
        building: building,
        floor: floor,
        networkType: networkType,
        usageDetail: usageDetail,
        signature: signature,
        verifiedAt: now,
      );
      return _items[idx];
    }

    final entry = AssetVerification(
      id: _nextId(),
      assetId: assetId,
      assetNumber: assetNumber,
      ownerName: ownerName,
      serialNumber: serialNumber,
      assetCategory: assetCategory,
      usageType: usageType,
      modelName: modelName,
      team: team,
      building: building,
      floor: floor,
      networkType: networkType,
      usageDetail: usageDetail,
      signature: signature,
      verifiedAt: now,
    );
    _items.add(entry);
    return entry;
  }

  String _nextId() {
    _idCounter += 1;
    return _idCounter.toString();
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
