import 'package:flutter/material.dart';

import '../model/asset_verification.dart';
import '../repository/asset_verification_repository.dart';

class AssetVerificationProvider extends ChangeNotifier {
  final AssetVerificationRepository repo = AssetVerificationRepository();

  List<AssetVerification> items = [];

  AssetVerificationProvider() {
    items = repo.list();
  }

  AssetVerification? getByAssetId(String assetId) => repo.getByAssetId(assetId);

  AssetVerification saveVerification({
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
    final saved = repo.save(
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
    );
    items = repo.list();
    notifyListeners();
    return saved;
  }
}
