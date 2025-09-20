// lib/view/screen/asset_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/asset_provider.dart';
import '../../provider/drawing_provider.dart';

enum AssetEditMode { create, update }

class AssetEditScreen extends StatelessWidget {
  const AssetEditScreen({super.key, required this.mode, this.id});
  final AssetEditMode mode;
  final String? id;

  @override
  Widget build(BuildContext context) {
    if (mode == AssetEditMode.create) {
      // 현재 Provider에는 create/update API가 없으므로 안내만 표시
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '자산 신규 생성은 아직 지원하지 않습니다.\n'
                '자산은 샘플 데이터로 제공되며, 위치 지정/변경만 가능합니다.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (id == null) {
      return const Center(child: Text('잘못된 접근입니다.'));
    }
    final ap = context.watch<AssetProvider>();
    final asset = ap.getById(id!);
    if (asset == null) {
      return const Center(child: Text('자산을 찾을 수 없습니다.'));
    }

    return _LocationEditor(assetId: asset.id);
  }
}

class _LocationEditor extends StatefulWidget {
  const _LocationEditor({required this.assetId});
  final String assetId;

  @override
  State<_LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<_LocationEditor> {
  String? _drawingId;
  final _row = TextEditingController(text: '0');
  final _col = TextEditingController(text: '0');

  @override
  void dispose() {
    _row.dispose();
    _col.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DrawingProvider>();
    final ap = context.watch<AssetProvider>();
    final asset = ap.getById(widget.assetId);
    if (asset == null) {
      return const Center(child: Text('자산을 찾을 수 없습니다.'));
    }

    final drawings = dp.items;

    // 기존 위치 프리필
    _drawingId ??= asset.locationDrawingId;
    if (asset.locationRow != null && _row.text == '0') {
      _row.text = asset.locationRow.toString();
    }
    if (asset.locationCol != null && _col.text == '0') {
      _col.text = asset.locationCol.toString();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('자산 위치 편집', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListTile(
            dense: true,
            leading: const Icon(Icons.info_outline),
            title: Text(asset.name),
            subtitle: Text('코드: ${asset.code} · 분류: ${asset.category}'),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final r = int.tryParse(_row.text) ?? 0;
                  final c = int.tryParse(_col.text) ?? 0;
                  try {
                    await context.read<AssetProvider>().setLocationAndSync(
                          assetId: widget.assetId,
                          drawingId: _drawingId,
                          row: _drawingId == null ? null : r,
                          col: _drawingId == null ? null : c,
                          drawingProvider: context.read<DrawingProvider>(),
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('위치가 저장되었습니다.')),
                      );
                    }
                  } on StateError catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('다른 2×2 영역과 겹칠 수 없습니다.')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('저장'),
              ),
              const SizedBox(width: 8),
              if (asset.locationDrawingId != null)
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AssetProvider>().setLocationAndSync(
                      assetId: widget.assetId,
                      drawingId: null,
                      row: null,
                      col: null,
                      drawingProvider: context.read<DrawingProvider>(),
                    );
                    if (context.mounted) {
                      setState(() {
                        _drawingId = null;
                        _row.text = '0';
                        _col.text = '0';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('위치를 해제했습니다.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('위치 해제'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '※ 위치 저장 시 도면의 해당 칸에 자동 등록되어 맵에 바로 표시됩니다.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
