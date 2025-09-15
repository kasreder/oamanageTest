import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/drawing.dart';
import '../provider/drawing_provider.dart';

/// Base path for bundled drawing images.
const String kDrawingImageAssetPath = 'lib/asset/locationmap/';

/// Mapping from drawing id to asset file name.
///
/// When more drawings are added, register the corresponding file here.
const Map<String, String> kDrawingImageFiles = {
  'D1': 'conco_11F_A.jpg',
  'D2': 'conco_11F_A.jpg',
  'D3': 'conco_11F_A.jpg',
  'D4': 'hankyung_16F_A.png',
  'D5': 'hankyung_16F_A.png',
  'D6': 'hankyung_16F_A.png',
  // Add additional mappings like 'D2': 'some_file.jpg'
};

/// Ensures that [drawing] has its background image loaded.
///
/// If the image bytes are already present this function does nothing. When the
/// image is missing and an asset file is registered for the drawing id or
/// supplied via [fileName], the bytes are loaded from the bundle and stored via
/// [DrawingProvider].
Future<void> loadDrawingImageIfNeeded(
  DrawingProvider dp,
  Drawing drawing, {
  String? fileName,
}) async {
  if (drawing.imageBytes != null && drawing.imageBytes!.isNotEmpty) return;
  final name = fileName ?? kDrawingImageFiles[drawing.id];
  if (name == null) return;
  try {
    final ByteData data = await rootBundle.load('$kDrawingImageAssetPath$name');
    final Uint8List bytes = data.buffer.asUint8List();
    await dp.setImageBytes(id: drawing.id, bytes: bytes, fileName: name);
  } catch (e) {
    debugPrint('Failed to load drawing image: $e');
  }
}
