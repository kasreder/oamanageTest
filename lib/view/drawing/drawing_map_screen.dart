// File Path: lib/view/drawing/drawing_map_screen.dart
// Features:
// - _DrawingMapScreenState.build (46~118행): 도면 정보 헤더, 배율 드롭다운, 캔버스 위젯을 배치합니다.
// - _DrawingCanvas.build (235~245행): 선택된 도면과 자산 데이터를 _GridOverlay에 전달합니다.
// - _GridOverlayState.build (352~520행): InteractiveViewer에서 배경, 격자, 마커 드래그/드롭을 처리합니다.
import 'dart:ui' as ui; // 이미지 원본 크기 확인
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/drawing_provider.dart';
import '../../provider/asset_provider.dart';
import '../../model/drawing.dart';
import '../../seed/grid_seed.dart';
import '../../util/drawing_image_loader.dart';
import '../../util/grid_marker.dart';

class DrawingMapScreen extends StatefulWidget {
  const DrawingMapScreen({super.key, required this.drawingId});

  final String drawingId;

  @override
  State<DrawingMapScreen> createState() => _DrawingMapScreenState();
}

class _DrawingMapScreenState extends State<DrawingMapScreen> {
  bool showMarkers = true;

  // ✅ 배율 상태(드롭다운)
  double _scale = 1.0;
  final List<double> _scaleOptions = [0.5, 1.0, 1.5, 2, 2.5, 3.0, 3.5, 4.0] ;

  @override
  void initState() {
    super.initState();
    final dp = context.read<DrawingProvider>();
    final d = dp.getById(widget.drawingId);
    if (d != null) {
      loadDrawingImageIfNeeded(dp, d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DrawingProvider>();
    final ap = context.watch<AssetProvider>();
    final Drawing? d = dp.getById(widget.drawingId);

    if (d == null) {
      return const Center(child: Text('도면을 찾을 수 없습니다.'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${d.building} · ${d.floor}  |  ${d.title}',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Text('마커 표시'),
                  Switch(
                    value: showMarkers,
                    onChanged: (v) => setState(() => showMarkers = v),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // ✅ 배율 드롭다운 버튼 (InteractiveViewer와 연동)
              DropdownButton<double>(
                value: _scale,
                items: _scaleOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('${(s * 100).toInt()}%'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _scale = v ?? _scale),
              ),

              const SizedBox(width: 8),
              // _GridControl(d: d), // 행/열 값은 여기서 바꿔 저장
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAllAssets(context, d),
                icon: const Icon(Icons.list),
                label: const Text('배치 자산 목록'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ Transform.scale 제거: 배율은 아래 InteractiveViewer 컨트롤러로만 처리
          Expanded(
            child: Center(
              child: _DrawingCanvas(
                d: d,
                showMarkers: showMarkers,
                assetProvider: ap,
                // ↓ 드롭다운에서 고른 배율을 전달
                scale: _scale,
                // ↓ 핀치/휠로 배율 변경되면 드롭다운 숫자도 동기화
                onScaleChanged: (s) => setState(() => _scale = s),
                // 드롭다운 허용 범위와 일치
                minScale: _scaleOptions.first,
                maxScale: _scaleOptions.last,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllAssets(BuildContext context, Drawing d) {
    final dp = context.read<DrawingProvider>();
    final ap = context.read<AssetProvider>();
    final ids = dp.allAssetIds(d.id);
    final assets = ids.map((id) => ap.getById(id)).whereType<dynamic>().toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: assets.isEmpty
            ? const Center(child: Text('배치된 자산이 없습니다.'))
            : ListView.separated(
                itemCount: assets.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a = assets[i];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(a.name),
                    subtitle: Text('코드: ${a.code} · 분류: ${a.category}'),
                  );
                },
              ),
      ),
    );
  }
}

class _GridControl extends StatefulWidget {
  const _GridControl({required this.d});

  final Drawing d;

  @override
  State<_GridControl> createState() => _GridControlState();
}

class _GridControlState extends State<_GridControl> {
  late int rows = widget.d.gridRows;
  late int cols = widget.d.gridCols;

  @override
  Widget build(BuildContext context) {
    return Row(
        // children: [
        //   const Text('행'),
        //   SizedBox(
        //     width: 56,
        //     child: TextFormField(
        //       initialValue: rows.toString(),
        //       textAlign: TextAlign.center,
        //       keyboardType: TextInputType.number,
        //       onFieldSubmitted: (_) => _apply(context),
        //       onChanged: (v) => rows = int.tryParse(v) ?? rows,
        //     ),
        //   ),
        //   const SizedBox(width: 8),
        //   const Text('열'),
        //   SizedBox(
        //     width: 56,
        //     child: TextFormField(
        //       initialValue: cols.toString(),
        //       textAlign: TextAlign.center,
        //       keyboardType: TextInputType.number,
        //       onFieldSubmitted: (_) => _apply(context),
        //       onChanged: (v) => cols = int.tryParse(v) ?? cols,
        //     ),
        //   ),
        //   const SizedBox(width: 8),
        //   FilledButton(
        //     onPressed: () => _apply(context),
        //     child: const Text('적용'),
        //   ),
        // ],
        );
  }

// Future<void> _apply(BuildContext context) async {
//   // 제한 해제: 큰 값도 허용
//   rows = rows.clamp(1, 1000000);
//   cols = cols.clamp(1, 1000000);
//   await context.read<DrawingProvider>().setGrid(id: widget.d.id, rows: rows, cols: cols);
// }
}

class _DrawingCanvas extends StatelessWidget {
  const _DrawingCanvas({
    required this.d,
    required this.assetProvider,
    required this.showMarkers,
    required this.scale,
    required this.onScaleChanged,
    this.minScale = 0.5,
    this.maxScale = 2.0,
  });

  final Drawing d;
  final AssetProvider assetProvider;
  final bool showMarkers;

  // ✅ 외부(상단 드롭다운)에서 지정한 배율
  final double scale;
  final ValueChanged<double> onScaleChanged;

  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return _GridOverlay(
      d: d,
      assetProvider: assetProvider,
      showMarkers: showMarkers,
      // ↓ 내부 InteractiveViewer 컨트롤러와 동기화
      scale: scale,
      onScaleChanged: onScaleChanged,
      minScale: minScale,
      maxScale: maxScale,
    );
  }
}

/// ✅ “비례 그리드” 버전 + 배율 연동
/// - 행/열(r,c)은 Drawing에 저장된 값을 고정 사용
/// - 화면 크기가 변하면 셀 크기만 비례 확대/축소
/// - 배율(드롭다운/핀치/휠)과 InteractiveViewer 컨트롤러 완전 연동
class _GridOverlay extends StatefulWidget {
  const _GridOverlay({
    required this.d,
    required this.assetProvider,
    required this.showMarkers,
    required this.scale,
    required this.onScaleChanged,
    required this.minScale,
    required this.maxScale,
  });

  final Drawing d;
  final AssetProvider assetProvider;
  final bool showMarkers;

  final double scale;
  final ValueChanged<double> onScaleChanged;
  final double minScale;
  final double maxScale;

  @override
  State<_GridOverlay> createState() => _GridOverlayState();
}

class _GridOverlayState extends State<_GridOverlay> {
  ui.Image? _decoded; // 원본 이미지(픽셀) 정보

  // ✅ 배율/이동 컨트롤러
  final TransformationController _tc = TransformationController();
  final GlobalKey _viewerKey = GlobalKey();

  int? _previewRow;
  int? _previewCol;
  bool _previewCanPlace = true;

  @override
  void initState() {
    super.initState();
    _decodeIfNeeded();
    _tc.value = Matrix4.identity()..scale(widget.scale);
  }

  @override
  void didUpdateWidget(covariant _GridOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 이미지 바뀌면 다시 디코딩
    if (oldWidget.d.imageBytes != widget.d.imageBytes) {
      _decoded = null;
      _decodeIfNeeded();
    }
    // 드롭다운에서 배율이 바뀌었으면 컨트롤러에 즉시 반영
    if (oldWidget.scale != widget.scale) {
      _tc.value = Matrix4.identity()..scale(widget.scale);
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _setPreview({int? row, int? col, bool canPlace = true}) {
    if (_previewRow != row || _previewCol != col || _previewCanPlace != canPlace) {
      setState(() {
        _previewRow = row;
        _previewCol = col;
        _previewCanPlace = canPlace;
      });
    }
  }

  void _clearPreview() {
    if (_previewRow != null || _previewCol != null || !_previewCanPlace) {
      setState(() {
        _previewRow = null;
        _previewCol = null;
        _previewCanPlace = true;
      });
    }
  }

  Offset? _globalToScene(Offset globalPosition) {
    final RenderObject? renderObject = _viewerKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }
    final Offset localPosition = renderObject.globalToLocal(globalPosition);
    return _tc.toScene(localPosition);
  }

  Future<void> _decodeIfNeeded() async {
    final bytes = widget.d.imageBytes;
    if (bytes == null) return;
    ui.decodeImageFromList(bytes, (img) {
      if (mounted) setState(() => _decoded = img);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final showMarkers = widget.showMarkers;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1) 화면 크기
        final contW = constraints.maxWidth;
        final contH = constraints.maxHeight;

        // 2) 이미지 원본 크기 (없으면 로딩)
        if (d.imageBytes != null && _decoded == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final imgW = (_decoded?.width ?? 1920).toDouble();
        final imgH = (_decoded?.height ?? 1080).toDouble();

        // 3) 이미지 비율 유지하여 "표시 캔버스" 크기 계산
        final scaleW = contW / imgW;
        final scaleH = contH / imgH;
        final baseScale = scaleW < scaleH ? scaleW : scaleH;
        final canvasW = imgW * baseScale;
        final canvasH = imgH * baseScale;

        // 4) 행/열(고정) → 셀 크기(비례 확장)
        //    ※ 실제 격자 크기는 아래에서 화면 크기 대비 셀 폭/높이로 결정됩니다.
        //       (격자 행/열 수가 바뀌면 cellW/cellH 값이 달라져 격자 크기가 조절됨)
        //       → 행/열 값은 Drawing.gridRows/gridCols에 저장되며,
        //         DrawingProvider.setGrid(...) (lib/provider/drawing_provider.dart)에서 변경합니다.
        // lib/seed/grid_seed.dart 에서 칸을 바꾸면 나옴
        final rows = d.gridRows;
        final cols = d.gridCols;
        final cellW = canvasW / cols;
        final cellH = canvasH / rows;

        // 5) 마커 좌표 (항상 r,c 기준 → 셀 중심)
        final markerWidth = cellW * Drawing.markerBlockSpan;
        final markerHeight = cellH * Drawing.markerBlockSpan;
        final double currentScaleValue = _tc.value.getMaxScaleOnAxis();
        final double markerScale = currentScaleValue > 0 ? currentScaleValue : 1.0;

        final markers = <Widget>[];
        if (showMarkers && d.cellAssets.isNotEmpty) {
          final grouped = groupAssetsByArea(
            cellAssets: d.cellAssets,
            rows: rows,
            cols: cols,
          );
          grouped.forEach((key, ids) {
            if (ids.isEmpty) return;
            final rc = parseCellKey(key);
            if (rc == null) return;
            final areaRow = rc.$1;
            final areaCol = rc.$2;
            if (areaRow < 0 || areaCol < 0 || areaRow >= rows || areaCol >= cols) return;

            final left = areaCol * cellW;
            final top = areaRow * cellH;
            final dragData = _MarkerDragData(
              row: areaRow,
              col: areaCol,
              assetIds: List<String>.from(ids),
            );

            markers.add(Positioned(
              left: left,
              top: top,
              width: markerWidth,
              height: markerHeight,
              child: LongPressDraggable<_MarkerDragData>(
                data: dragData,
                feedback: SizedBox(
                  width: markerWidth * markerScale,
                  height: markerHeight * markerScale,
                  child: IgnorePointer(
                    ignoring: true,
                    child: _AssetMarker(
                      count: ids.length,
                      onTap: () {},
                      isDragging: true,
                    ),
                  ),
                ),
                childWhenDragging: const SizedBox.shrink(),
                child: _AssetMarker(
                  count: ids.length,
                  onTap: () => _openCellDialog(context, d, areaRow, areaCol),
                ),
              ),
            ));
          });
        }

        // 6) InteractiveViewer: 배율/이동(컨트롤러 연동)
        return Center(
          child: InteractiveViewer(
            key: _viewerKey,
            transformationController: _tc,
            // ✅ 배율 연동 포인트
            constrained: false,
            boundaryMargin: const EdgeInsets.all(300),
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            onInteractionEnd: (_) {
              // 핀치/휠로 배율 바꿨을 때 드롭다운에 반영
              final s = _tc.value.getMaxScaleOnAxis();
              widget.onScaleChanged(double.parse(s.toStringAsFixed(2)));
            },
            child: SizedBox(
              width: canvasW,
              height: canvasH,
              child: Stack(
                children: [
                  // (1) 배경 그림: 캔버스 사이즈에 정확히 맞춤(비율 동일)
                  if (d.imageBytes != null)
                    Positioned.fill(
                      child: Image.memory(
                        d.imageBytes!,
                        width: canvasW,
                        height: canvasH,
                        fit: BoxFit.fill, // 캔버스와 이미지 비율이 같으므로 fill OK
                        filterQuality: FilterQuality.high,
                      ),
                    ),

                  // (2) 격자: 행/열 고정, 셀 크기만 비례
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainterProportional(
                        rows: rows,
                        cols: cols,
                        canvasW: canvasW,
                        canvasH: canvasH,
                      ),
                    ),
                  ),

                  // (3) 탭: 캔버스 좌표 → (r,c)
                  Positioned.fill(
                    child: Builder(
                      builder: (dragContext) {
                        return DragTarget<_MarkerDragData>(
                          onWillAccept: (_) => true,
                          onMove: (details) {
                            final scene = _globalToScene(details.offset);
                            if (scene == null) return;
                            _updatePreview(
                              data: details.data,
                              scenePosition: scene,
                              canvasW: canvasW,
                              canvasH: canvasH,
                              cellW: cellW,
                              cellH: cellH,
                              rows: rows,
                              cols: cols,
                            );
                          },
                          onLeave: (_) => _clearPreview(),
                          onAcceptWithDetails: (details) async {
                            final scene = _globalToScene(details.offset);
                            if (scene == null) return;
                            await _handleMarkerDrop(
                              context: dragContext,
                              data: details.data,
                              scenePosition: scene,
                              canvasW: canvasW,
                              canvasH: canvasH,
                              cellW: cellW,
                              cellH: cellH,
                              rows: rows,
                              cols: cols,
                            );
                          },
                          builder: (context, candidate, rejected) {
                            return _CellTappableAreaProportional(
                              rows: rows,
                              cols: cols,
                              canvasW: canvasW,
                              canvasH: canvasH,
                              onCellTap: (r, c) => _openCellDialog(context, d, r, c),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // (4) 마커
                  ...markers,

                  // (5) 드래그 위치 미리보기
                  if (_previewRow != null && _previewCol != null)
                    Positioned(
                      left: _previewCol! * cellW,
                      top: _previewRow! * cellH,
                      width: markerWidth,
                      height: markerHeight,
                      child: IgnorePointer(
                        ignoring: true,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // 드래그 미리보기 배경 색상(보라: 배치 가능, 빨강: 충돌)과 투명도
                            color: (_previewCanPlace
                                    ? Colors.deepPurpleAccent
                                    : Colors.redAccent)
                                .withOpacity(0.3),
                            border: Border.all(
                              // 미리보기 테두리 색상/두께(2px)도 동일하게 맞춰 강조
                              color: _previewCanPlace
                                  ? Colors.deepPurpleAccent
                                  : Colors.redAccent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMarkerDrop({
    required BuildContext context,
    required _MarkerDragData data,
    required Offset scenePosition,
    required double canvasW,
    required double canvasH,
    required double cellW,
    required double cellH,
    required int rows,
    required int cols,
  }) async {
    _clearPreview();

    if (data.assetIds.isEmpty || rows <= 0 || cols <= 0) {
      return;
    }

    double dx = scenePosition.dx;
    double dy = scenePosition.dy;
    if (dx.isNaN || dy.isNaN) {
      return;
    }
    if (canvasW > 0) {
      dx = dx.clamp(0.0, canvasW - 0.0001);
    }
    if (canvasH > 0) {
      dy = dy.clamp(0.0, canvasH - 0.0001);
    }

    int rawCol = (dx / cellW).floor();
    int rawRow = (dy / cellH).floor();
    rawRow = rawRow.clamp(0, rows - 1);
    rawCol = rawCol.clamp(0, cols - 1);

    final normalized = normalizeBlockOrigin(
      row: rawRow,
      col: rawCol,
      rows: rows,
      cols: cols,
    );
    final targetRow = normalized.$1;
    final targetCol = normalized.$2;

    if (targetRow == data.row && targetCol == data.col) {
      return;
    }

    final drawingProvider = context.read<DrawingProvider>();
    final drawing = drawingProvider.getById(widget.d.id);
    if (drawing == null) {
      return;
    }

    final canPlace = canPlaceMarker(
      cellAssets: drawing.cellAssets,
      row: targetRow,
      col: targetCol,
      rows: drawing.gridRows,
      cols: drawing.gridCols,
      ignoreKey: data.areaKey,
    );
    if (!canPlace) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('다른 2×2 영역과 겹칠 수 없습니다.')),
      );
      return;
    }

    try {
      for (final assetId in data.assetIds) {
        await widget.assetProvider.setLocationAndSync(
          assetId: assetId,
          drawingId: drawing.id,
          row: targetRow,
          col: targetCol,
          drawingProvider: drawingProvider,
        );
      }
    } on StateError catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('다른 2×2 영역과 겹칠 수 없습니다.')),
      );
    }
  }

  void _updatePreview({
    required _MarkerDragData data,
    required Offset scenePosition,
    required double canvasW,
    required double canvasH,
    required double cellW,
    required double cellH,
    required int rows,
    required int cols,
  }) {
    if (scenePosition.dx.isNaN || scenePosition.dy.isNaN) {
      return;
    }

    if (scenePosition.dx < 0 ||
        scenePosition.dy < 0 ||
        scenePosition.dx >= canvasW ||
        scenePosition.dy >= canvasH) {
      _clearPreview();
      return;
    }
    int rawCol = (scenePosition.dx / cellW).floor();
    int rawRow = (scenePosition.dy / cellH).floor();
    rawRow = rawRow.clamp(0, rows - 1);
    rawCol = rawCol.clamp(0, cols - 1);

    final normalized = normalizeBlockOrigin(
      row: rawRow,
      col: rawCol,
      rows: rows,
      cols: cols,
    );
    final targetRow = normalized.$1;
    final targetCol = normalized.$2;

    final drawing = widget.d;
    final canPlace = canPlaceMarker(
      cellAssets: drawing.cellAssets,
      row: targetRow,
      col: targetCol,
      rows: drawing.gridRows,
      cols: drawing.gridCols,
      ignoreKey: data.areaKey,
    );

    _setPreview(row: targetRow, col: targetCol, canPlace: canPlace);
  }

  void _openCellDialog(BuildContext context, Drawing d, int row, int col) {
    final dp = context.read<DrawingProvider>();
    final ap = context.read<AssetProvider>();

    final normalized = normalizeBlockOrigin(
      row: row,
      col: col,
      rows: d.gridRows,
      cols: d.gridCols,
    );
    final areaRow = normalized.$1;
    final areaCol = normalized.$2;
    final currentIds = collectAreaAssetIds(
      cellAssets: d.cellAssets,
      row: areaRow,
      col: areaCol,
      rows: d.gridRows,
      cols: d.gridCols,
    ).toList();
    final currentAssets = currentIds.map((id) => ap.getById(id)).whereType<dynamic>().toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('자리: ($areaRow, $areaCol)', style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (currentAssets.isEmpty)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('배치된 자산이 없습니다.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: currentAssets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = currentAssets[i];
                      return ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text(a.name),
                        subtitle: Text('코드: ${a.code} · 분류: ${a.category}'),
                        trailing: IconButton(
                          tooltip: '제거',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            await sheetContext.read<AssetProvider>().setLocationAndSync(
                                  assetId: a.id,
                                  drawingId: null,
                                  row: null,
                                  col: null,
                                  drawingProvider: dp,
                                );
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            _openCellDialog(context, dp.getById(d.id)!, areaRow, areaCol);
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final selected = await _openAssetPicker(sheetContext, ap);
                  if (selected == null) return;
                  try {
                    await sheetContext.read<AssetProvider>().setLocationAndSync(
                          assetId: selected.id,
                          drawingId: d.id,
                          row: areaRow,
                          col: areaCol,
                          drawingProvider: dp,
                        );
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    _openCellDialog(context, dp.getById(d.id)!, areaRow, areaCol);
                  } on StateError catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('다른 2×2 영역과 겹칠 수 없습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('자산 추가'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic /*Asset?*/ > _openAssetPicker(BuildContext context, AssetProvider ap) async {
    final items = ap.items;
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('자산 선택'),
        content: SizedBox(
          width: 460,
          height: 400,
          child: items.isEmpty
              ? const Center(child: Text('자산 데이터가 없습니다.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(a.name),
                      subtitle: Text('코드: ${a.code} · 분류: ${a.category}'),
                      onTap: () => Navigator.of(dialogContext).pop(a),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class _AssetMarker extends StatelessWidget {
  const _AssetMarker({
    required this.count,
    required this.onTap,
    this.isDragging = false,
  });

  final int count;
  final VoidCallback onTap;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    // 마커 타일의 기본 색상(드래그 중일 땐 투명도를 더 낮춰 살짝 흐리게 표시)
    final baseColor = Color(GridSeed.markerColorHex);
    final color = baseColor.withOpacity(
      isDragging ? GridSeed.markerDraggingOpacity : GridSeed.markerOpacity,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            // 테두리를 밝은 흰색(투명도 0.9)과 두께 2px로 주어 격자 위에서도 눈에 띄게
            border: Border.all(
              color: Color(GridSeed.markerBorderColorHex),
              width: GridSeed.markerBorderStrokeWidth,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerDragData {
  _MarkerDragData({
    required this.row,
    required this.col,
    required List<String> assetIds,
  })  : assetIds = List<String>.unmodifiable(assetIds),
        areaKey = cellKeyFrom(row: row, col: col);

  final int row;
  final int col;
  final List<String> assetIds;
  final String areaKey;
}

/// 비례 격자 페인터: canvasW/H를 열/행으로 균등 분할해서 선을 그림
class _GridPainterProportional extends CustomPainter {
  _GridPainterProportional({
    required this.rows,
    required this.cols,
    required this.canvasW,
    required this.canvasH,
  });

  final int rows;
  final int cols;
  final double canvasW;
  final double canvasH;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = Color(GridSeed.borderColorHex)
      ..strokeWidth = GridSeed.borderStrokeWidth;
    final grid = Paint()
      ..color = Color(GridSeed.gridColorHex)
      ..strokeWidth = GridSeed.gridStrokeWidth;

    // 외곽
    final rect = Rect.fromLTWH(0, 0, canvasW, canvasH);
    canvas.drawRect(rect, border..style = PaintingStyle.stroke);

    // 세로선 (열)
    final cellW = canvasW / cols;
    for (int c = 1; c < cols; c++) {
      final x = cellW * c;
      canvas.drawLine(Offset(x, 0), Offset(x, canvasH), grid);
    }
    // 가로선 (행)
    final cellH = canvasH / rows;
    for (int r = 1; r < rows; r++) {
      final y = cellH * r;
      canvas.drawLine(Offset(0, y), Offset(canvasW, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainterProportional old) => old.rows != rows || old.cols != cols || old.canvasW != canvasW || old.canvasH != canvasH;
}

/// 탭 → (r,c) 환산: 캔버스 크기를 행/열로 균등 분할해서 역산
class _CellTappableAreaProportional extends StatelessWidget {
  const _CellTappableAreaProportional({
    required this.rows,
    required this.cols,
    required this.canvasW,
    required this.canvasH,
    required this.onCellTap,
  });

  final int rows;
  final int cols;
  final double canvasW;
  final double canvasH;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(d.globalPosition);

        if (local.dx < 0 || local.dy < 0 || local.dx >= canvasW || local.dy >= canvasH) {
          return; // 캔버스 밖 무시
        }

        if (cols <= 0 || rows <= 0) {
          return;
        }

        final cellW = canvasW / cols;
        final cellH = canvasH / rows;

        int c = (local.dx / cellW).floor();
        int r = (local.dy / cellH).floor();
        c = c.clamp(0, cols - 1);
        r = r.clamp(0, rows - 1);

        final normalized = normalizeBlockOrigin(
          row: r,
          col: c,
          rows: rows,
          cols: cols,
        );
        onCellTap(normalized.$1, normalized.$2);
      },
    );
  }
}
