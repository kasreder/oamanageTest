// lib/model/asset.dart
class Asset {
  /// 오름차순 순번 (문자열로 보관하지만 "1","2","3"... 형태)
  final String id;

  /// 알파벳 1 + 숫자 5 (예: A01234) - 고유
  String code;

  /// 자산명
  String name;

  /// 분류 (예: 생산설비, IT장비 등)
  String category;

  /// 시리얼번호
  String serialNumber;

  /// 모델명
  String modelName;

  /// 공급사/제조사
  String vendor;

  /// 위치(선택)
  String? locationDrawingId;
  int? locationRow;
  int? locationCol;

  DateTime createdAt;
  DateTime updatedAt;

  Asset({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.serialNumber,
    required this.modelName,
    required this.vendor,
    this.locationDrawingId,
    this.locationRow,
    this.locationCol,
    required this.createdAt,
    required this.updatedAt,
  });

  Asset copyWith({
    String? code,
    String? name,
    String? category,
    String? serialNumber,
    String? modelName,
    String? vendor,
    String? locationDrawingId,
    int? locationRow,
    int? locationCol,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      serialNumber: serialNumber ?? this.serialNumber,
      modelName: modelName ?? this.modelName,
      vendor: vendor ?? this.vendor,
      locationDrawingId: locationDrawingId ?? this.locationDrawingId,
      locationRow: locationRow ?? this.locationRow,
      locationCol: locationCol ?? this.locationCol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
