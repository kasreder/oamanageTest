// lib/view/screen/asset_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/asset_provider.dart';
import '../../provider/drawing_provider.dart';
import 'package:go_router/go_router.dart';
import '../../util/drawing_image_loader.dart';

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssetProvider>();
    final dp = context.watch<DrawingProvider>();
    final asset = ap.getById(id);

    if (asset == null) {
      return const Center(child: Text('자산을 찾을 수 없습니다.'));
    }

    final hasLoc = asset.locationDrawingFile != null && asset.locationDrawingId != null;
    String locStr;
    if (hasLoc) {
      final parts = asset.locationDrawingFile!.split('_');
      final building = parts.isNotEmpty ? parts[0] : '';
      final floor = parts.length > 1 ? parts[1] : '';
      locStr = '$building, $floor (${asset.locationRow}, ${asset.locationCol})';
    } else {
      locStr = '미지정';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(asset.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          _kv('코드', asset.code),
          _kv('분류', asset.category),
          _kv('위치', locStr),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hasLoc)
                FilledButton.icon(
                  onPressed: () async {
                    // 도면 배경이 없으면 자산에 지정된 파일을 로드 후 이동
                    final d = dp.getById(asset.locationDrawingId!);
                    if (d != null) {
                      await loadDrawingImageIfNeeded(
                        dp,
                        d,
                        fileName: asset.locationDrawingFile,
                      );
                    }
                    if (context.mounted) {
                      context.push('/drawing/${asset.locationDrawingId}/map');
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('도면에서 보기'),
                ),
              FilledButton.icon(
                onPressed: () => _openLocationEditor(context, asset.id),
                icon: const Icon(Icons.edit_location_alt),
                label: Text(hasLoc ? '위치 변경' : '위치 지정'),
              ),
              if (hasLoc)
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AssetProvider>().setLocationAndSync(
                      assetId: asset.id,
                      drawingId: null,
                      row: null,
                      col: null,
                      drawingProvider: context.read<DrawingProvider>(),
                    );
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('위치 해제'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('메모/이력 등 추가 섹션은 추후 확장 가능'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Future<void> _openLocationEditor(BuildContext context, String assetId) async {
    await showDialog(
      context: context,
      builder: (_) => _LocationDialog(assetId: assetId),
    );
  }
}

class _LocationDialog extends StatefulWidget {
  const _LocationDialog({required this.assetId});
  final String assetId;

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  String? _drawingId;
  final _row = TextEditingController(text: '0');
  final _col = TextEditingController(text: '0');
  final _file = TextEditingController();

  @override
  void dispose() {
    _row.dispose();
    _col.dispose();
    _file.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DrawingProvider>();
    final drawings = dp.items; // 현재 리스트 사용

    return AlertDialog(
      title: const Text('자산 위치 지정'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _drawingId,
              decoration: const InputDecoration(labelText: '도면 선택'),
              items: drawings
                  .map((d) => DropdownMenuItem(
                value: d.id,
                child: Text('${d.building} · ${d.floor} · ${d.title}'),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _drawingId = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _file,
              decoration: const InputDecoration(labelText: '도면 파일명'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _row,
                    decoration: const InputDecoration(labelText: '행 (0-based)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _col,
                    decoration: const InputDecoration(labelText: '열 (0-based)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 지정한 칸으로 도면에 자동 등록됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () async {
            final r = int.tryParse(_row.text) ?? 0;
            final c = int.tryParse(_col.text) ?? 0;
            await context.read<AssetProvider>().setLocationAndSync(
              assetId: widget.assetId,
              drawingId: _drawingId,
              row: _drawingId == null ? null : r,
              col: _drawingId == null ? null : c,
              drawingFile: _file.text.isEmpty ? null : _file.text,
              drawingProvider: context.read<DrawingProvider>(),
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
