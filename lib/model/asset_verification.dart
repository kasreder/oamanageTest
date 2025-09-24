class AssetVerification {
  final String id;
  final String assetId;
  final String assetNumber;
  final String ownerName;
  final String serialNumber;
  final String assetCategory;
  final String usageType;
  final String modelName;
  final String team;
  final String building;
  final String floor;
  final String networkType;
  final String usageDetail;
  final String signature;
  final DateTime verifiedAt;

  AssetVerification({
    required this.id,
    required this.assetId,
    required this.assetNumber,
    required this.ownerName,
    required this.serialNumber,
    required this.assetCategory,
    required this.usageType,
    required this.modelName,
    required this.team,
    required this.building,
    required this.floor,
    required this.networkType,
    required this.usageDetail,
    required this.signature,
    required this.verifiedAt,
  });

  AssetVerification copyWith({
    String? assetNumber,
    String? ownerName,
    String? serialNumber,
    String? assetCategory,
    String? usageType,
    String? modelName,
    String? team,
    String? building,
    String? floor,
    String? networkType,
    String? usageDetail,
    String? signature,
    DateTime? verifiedAt,
  }) {
    return AssetVerification(
      id: id,
      assetId: assetId,
      assetNumber: assetNumber ?? this.assetNumber,
      ownerName: ownerName ?? this.ownerName,
      serialNumber: serialNumber ?? this.serialNumber,
      assetCategory: assetCategory ?? this.assetCategory,
      usageType: usageType ?? this.usageType,
      modelName: modelName ?? this.modelName,
      team: team ?? this.team,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      networkType: networkType ?? this.networkType,
      usageDetail: usageDetail ?? this.usageDetail,
      signature: signature ?? this.signature,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
