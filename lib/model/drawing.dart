// lib/model/drawing.dart
import 'dart:typed_data';

/// 도면 모델 (건물 · 층별)
class Drawing {
  final String id;           // 고유 ID
  final String building;           // 건물명
  final String floor;              // 층 (예: B1, 1F, 2F)
  final String title;              // 도면 제목
  final String? note;              // 비고(선택)

  // 업로드된 도면 이미지(배경)
  Uint8List? imageBytes;     // PNG/JPG/WEBP/SVG(web) 등
  String? imageName;         // 원본 파일명
  DateTime? imageUpdatedAt;  // 업로드 시각

  // 격자 설정 (기본 12 x 18)
  int gridRows;
  int gridCols;

  // 칸 -> 자산ID 목록 (예: "r3c5" -> ["A1001","A2002"])
  Map<String, List<String>> cellAssets;

  DateTime createdAt;
  DateTime updatedAt;

  Drawing({
    required this.id,
    required this.building,
    required this.floor,
    required this.title,
    this.note,
    this.imageBytes,
    this.imageName,
    this.imageUpdatedAt,
    this.gridRows = 2000,
    this.gridCols = 2000,
    Map<String, List<String>>? cellAssets,
    required this.createdAt,
    required this.updatedAt,
  }) : cellAssets = cellAssets ?? <String, List<String>>{};

  Drawing copyWith({
    String? building,
    String? floor,
    String? title,
    String? note,
    Uint8List? imageBytes,
    String? imageName,
    DateTime? imageUpdatedAt,
    int? gridRows,
    int? gridCols,
    Map<String, List<String>>? cellAssets,
    DateTime? updatedAt,
  }) {
    return Drawing(
      id: id,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      title: title ?? this.title,
      note: note ?? this.note,
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
      imageUpdatedAt: imageUpdatedAt ?? this.imageUpdatedAt,
      gridRows: gridRows ?? this.gridRows,
      gridCols: gridCols ?? this.gridCols,
      cellAssets: cellAssets ?? Map<String, List<String>>.from(this.cellAssets),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
