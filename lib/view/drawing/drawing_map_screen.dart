// lib/view/drawing/drawing_map_screen.dart
import 'dart:ui' as ui; // 이미지 원본 크기 확인
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/drawing_provider.dart';
import '../../provider/asset_provider.dart';
import '../../model/drawing.dart';
import '../../util/drawing_image_loader.dart';

// (선택) 격자/테두리 색만 모아두고 싶다면 상수로 둡니다.
const _kGridColor = Color(0x18000000);   // 검정(연한)
const _kBorderColor = Color(0xFF000000); // 검정

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
  final List<double> _scaleOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.25, 2.5, 3.0];

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
    final ap = widget.assetProvider;
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
        final rows = d.gridRows;
        final cols = d.gridCols;
        final cellW = canvasW / cols;
        final cellH = canvasH / rows;

        // 5) 마커 좌표 (항상 r,c 기준 → 셀 중심)
        final markers = <Widget>[];
        if (showMarkers && d.cellAssets.isNotEmpty) {
          d.cellAssets.forEach((key, ids) {
            if (ids.isEmpty) return;
            final rc = _parseCellKey(key);
            if (rc == null) return;
            final r = rc.$1;
            final c = rc.$2;
            if (r < 0 || c < 0 || r >= rows || c >= cols) return;

            final left = c * cellW + cellW / 2;
            final top  = r * cellH + cellH / 2;

            markers.add(Positioned(
              left: left - 14,
              top: top - 14,
              width: 15,
              height: 15,
              child: _AssetMarker(
                count: ids.length,
                onTap: () => _openCellDialog(context, d, r, c),
              ),
            ));
          });
        }

        // 6) InteractiveViewer: 배율/이동(컨트롤러 연동)
        return Center(
          child: InteractiveViewer(
            transformationController: _tc, // ✅ 배율 연동 포인트
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
                    child: _CellTappableAreaProportional(
                      rows: rows,
                      cols: cols,
                      canvasW: canvasW,
                      canvasH: canvasH,
                      onCellTap: (r, c) => _openCellDialog(context, d, r, c),
                    ),
                  ),

                  // (4) 마커
                  ...markers,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  (int, int)? _parseCellKey(String key) {
    try {
      final rIdx = key.indexOf('r');
      final cIdx = key.indexOf('c');
      if (rIdx != 0 || cIdx < 0) return null;
      final r = int.parse(key.substring(1, cIdx));
      final c = int.parse(key.substring(cIdx + 1));
      return (r, c);
    } catch (_) {
      return null;
    }
  }

  void _openCellDialog(BuildContext context, Drawing d, int row, int col) {
    final dp = context.read<DrawingProvider>();
    final ap = context.read<AssetProvider>();

    final key = 'r${row}c$col';
    final currentIds = List<String>.from(d.cellAssets[key] ?? const []);
    final currentAssets =
    currentIds.map((id) => ap.getById(id)).whereType<dynamic>().toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 12,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('자리: ($row, $col)', style: Theme.of(sheetContext).textTheme.titleMedium),
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
                            await dp.removeAssetFromCell(id: d.id, row: row, col: col, assetId: a.id);
                            await sheetContext.read<AssetProvider>().setLocationAndSync(
                              assetId: a.id, drawingId: null, row: null, col: null,
                              drawingProvider: dp,
                            );
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            _openCellDialog(context, dp.getById(d.id)!, row, col);
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
                  await sheetContext.read<AssetProvider>().setLocationAndSync(
                    assetId: selected.id, drawingId: d.id, row: row, col: col,
                    drawingProvider: dp,
                  );
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  _openCellDialog(context, dp.getById(d.id)!, row, col);
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

  Future<dynamic /*Asset?*/ > _openAssetPicker(
      BuildContext context, AssetProvider ap) async {
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
  const _AssetMarker({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      ..color = _kBorderColor
      ..strokeWidth = 2.0;
    final grid = Paint()
      ..color = _kGridColor
      ..strokeWidth = 1.0;

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
  bool shouldRepaint(covariant _GridPainterProportional old) =>
      old.rows != rows ||
          old.cols != cols ||
          old.canvasW != canvasW ||
          old.canvasH != canvasH;
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

        final cellW = canvasW / cols;
        final cellH = canvasH / rows;

        final c = (local.dx / cellW).floor().clamp(0, cols - 1);
        final r = (local.dy / cellH).floor().clamp(0, rows - 1);
        onCellTap(r, c);
      },
    );
  }
}
