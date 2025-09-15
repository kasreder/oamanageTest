// lib/view/screen/asset_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/asset_provider.dart';
import '../../provider/drawing_provider.dart';
import 'package:go_router/go_router.dart';
import '../../util/drawing_image_loader.dart';
import '../../model/asset.dart';

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

    final hasLoc = asset.locationRow != null && asset.locationCol != null;
    String locStr;
    if (hasLoc) {
      String building = asset.building ?? '';
      String floor = asset.floor ?? '';
      if (asset.locationDrawingFile != null) {
        final parts = asset.locationDrawingFile!.split('_');
        if (parts.length >= 2) {
          building = parts[0];
          floor = parts[1];
        }
      }
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
          _kv('모델명', asset.modelName),
          _kv('제조사', asset.vendor),
          _kv('네트워크', asset.network ?? '-'),
          _kv('시리얼', asset.serialNumber),
          _kv('건물', asset.building ?? '-'),
          _kv('층', asset.floor ?? '-'),
          _kv('담당자', asset.memberName ?? '-'),
          _kv('위치', locStr),
          _kv('실물점검일', asset.physicalCheckDate?.toIso8601String() ?? '-'),
          _kv('검수일자', asset.confirmationDate?.toIso8601String() ?? '-'),
          _kv('일반비고', asset.normalComment ?? '-'),
          _kv('OA비고', asset.oaComment ?? '-'),
          _kv('MAC', asset.macAddress ?? '-'),
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
              OutlinedButton.icon(
                onPressed: () => _openAssetEditor(context, asset),
                icon: const Icon(Icons.edit),
                label: const Text('정보 수정'),
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

  Future<void> _openAssetEditor(BuildContext context, Asset asset) async {
    await showDialog(
      context: context,
      builder: (_) => _AssetEditDialog(asset: asset),
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

class _AssetEditDialog extends StatefulWidget {
  const _AssetEditDialog({required this.asset});
  final Asset asset;

  @override
  State<_AssetEditDialog> createState() => _AssetEditDialogState();
}

class _AssetEditDialogState extends State<_AssetEditDialog> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _serial;
  late final TextEditingController _model;
  late final TextEditingController _vendor;
  late final TextEditingController _network;
  late final TextEditingController _building;
  late final TextEditingController _floor;
  late final TextEditingController _member;
  late final TextEditingController _physical;
  late final TextEditingController _confirm;
  late final TextEditingController _normal;
  late final TextEditingController _oa;
  late final TextEditingController _mac;

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _code = TextEditingController(text: a.code);
    _name = TextEditingController(text: a.name);
    _category = TextEditingController(text: a.category);
    _serial = TextEditingController(text: a.serialNumber);
    _model = TextEditingController(text: a.modelName);
    _vendor = TextEditingController(text: a.vendor);
    _network = TextEditingController(text: a.network ?? '');
    _building = TextEditingController(text: a.building ?? '');
    _floor = TextEditingController(text: a.floor ?? '');
    _member = TextEditingController(text: a.memberName ?? '');
    _physical = TextEditingController(text: a.physicalCheckDate?.toIso8601String() ?? '');
    _confirm = TextEditingController(text: a.confirmationDate?.toIso8601String() ?? '');
    _normal = TextEditingController(text: a.normalComment ?? '');
    _oa = TextEditingController(text: a.oaComment ?? '');
    _mac = TextEditingController(text: a.macAddress ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _category.dispose();
    _serial.dispose();
    _model.dispose();
    _vendor.dispose();
    _network.dispose();
    _building.dispose();
    _floor.dispose();
    _member.dispose();
    _physical.dispose();
    _confirm.dispose();
    _normal.dispose();
    _oa.dispose();
    _mac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('자산 정보 수정'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _code, decoration: const InputDecoration(labelText: '코드')),
              TextField(controller: _name, decoration: const InputDecoration(labelText: '자산명')),
              TextField(controller: _category, decoration: const InputDecoration(labelText: '분류')),
              TextField(controller: _serial, decoration: const InputDecoration(labelText: '시리얼')),
              TextField(controller: _model, decoration: const InputDecoration(labelText: '모델명')),
              TextField(controller: _vendor, decoration: const InputDecoration(labelText: '제조사')),
              TextField(controller: _network, decoration: const InputDecoration(labelText: '네트워크')),
              TextField(controller: _building, decoration: const InputDecoration(labelText: '건물')),
              TextField(controller: _floor, decoration: const InputDecoration(labelText: '층')),
              TextField(controller: _member, decoration: const InputDecoration(labelText: '담당자')),
              TextField(controller: _physical, decoration: const InputDecoration(labelText: '실물점검일(YYYY-MM-DD)')),
              TextField(controller: _confirm, decoration: const InputDecoration(labelText: '검수일자(YYYY-MM-DD)')),
              TextField(controller: _normal, decoration: const InputDecoration(labelText: '일반비고')),
              TextField(controller: _oa, decoration: const InputDecoration(labelText: 'OA비고')),
              TextField(controller: _mac, decoration: const InputDecoration(labelText: 'MAC 주소')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () {
            final updated = widget.asset.copyWith(
              code: _code.text,
              name: _name.text,
              category: _category.text,
              serialNumber: _serial.text,
              modelName: _model.text,
              vendor: _vendor.text,
              network: _network.text.isEmpty ? null : _network.text,
              building: _building.text.isEmpty ? null : _building.text,
              floor: _floor.text.isEmpty ? null : _floor.text,
              memberName: _member.text.isEmpty ? null : _member.text,
              physicalCheckDate: _physical.text.isEmpty ? null : DateTime.tryParse(_physical.text),
              confirmationDate: _confirm.text.isEmpty ? null : DateTime.tryParse(_confirm.text),
              normalComment: _normal.text.isEmpty ? null : _normal.text,
              oaComment: _oa.text.isEmpty ? null : _oa.text,
              macAddress: _mac.text.isEmpty ? null : _mac.text,
            );
            context.read<AssetProvider>().update(updated);
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
