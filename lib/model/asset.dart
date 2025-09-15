// lib/model/asset.dart

const _unset = Object();

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

  /// 네트워크 구분
  String? network;

  /// 실물 점검일
  DateTime? physicalCheckDate;

  /// 검수일자
  DateTime? confirmationDate;

  /// 일반 비고 (100자 이내)
  String? normalComment;

  /// OA 비고 (100자 이내)
  String? oaComment;

  /// MAC 주소
  String? macAddress;

  /// 건물명(선택)
  String? building;

  /// 층(선택)
  String? floor;

  /// 담당자명(선택)
  String? memberName;

  /// 위치(선택)
  String? locationDrawingId;
  int? locationRow;
  int? locationCol;
  /// 도면 파일명(배경)
  String? locationDrawingFile;

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
    this.network,
    this.physicalCheckDate,
    this.confirmationDate,
    this.normalComment,
    this.oaComment,
    this.macAddress,
    this.building,
    this.floor,
    this.memberName,
    this.locationDrawingId,
    this.locationRow,
    this.locationCol,
    this.locationDrawingFile,
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
    String? network,
    DateTime? physicalCheckDate,
    DateTime? confirmationDate,
    String? normalComment,
    String? oaComment,
    String? macAddress,
    String? building,
    String? floor,
    String? memberName,
    String? locationDrawingId,
    int? locationRow,
    int? locationCol,
    Object? locationDrawingFile = _unset,
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
      network: network ?? this.network,
      physicalCheckDate: physicalCheckDate ?? this.physicalCheckDate,
      confirmationDate: confirmationDate ?? this.confirmationDate,
      normalComment: normalComment ?? this.normalComment,
      oaComment: oaComment ?? this.oaComment,
      macAddress: macAddress ?? this.macAddress,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      memberName: memberName ?? this.memberName,
      locationDrawingId: locationDrawingId ?? this.locationDrawingId,
      locationRow: locationRow ?? this.locationRow,
      locationCol: locationCol ?? this.locationCol,
      locationDrawingFile: locationDrawingFile == _unset
          ? this.locationDrawingFile
          : locationDrawingFile as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
