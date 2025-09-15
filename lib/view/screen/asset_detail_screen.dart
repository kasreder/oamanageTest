// lib/view/screen/asset_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/asset_provider.dart';
import '../../provider/drawing_provider.dart';
import '../../util/drawing_image_loader.dart';
import '../../model/asset.dart';

String _fmtDate(DateTime? d) =>
    d == null ? '' : d.toIso8601String().split('T').first;

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
      final building = asset.building ?? '';
      final floor = asset.floor ?? '';
      locStr = '$building, $floor (${asset.locationRow}, ${asset.locationCol})';
    } else {
      locStr = '미지정';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(asset.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          _kv('코드', asset.code),
          _kv('분류', asset.category),
          _kv('시리얼', asset.serialNumber),
          _kv('모델명', asset.modelName),
          _kv('제조사', asset.vendor),
          _kv('건물', asset.building),
          _kv('층', asset.floor),
          _kv('담당자', asset.memberName),
          _kv('망', asset.network),
          _kv('실사일', _fmtDate(asset.physicalCheckDate)),
          _kv('확정일', _fmtDate(asset.confirmationDate)),
          _kv('일반비고', asset.normalComment),
          _kv('OA비고', asset.oaComment),
          _kv('MAC', asset.macAddress),
          _kv('위치', locStr),
          _kv('생성일', _fmtDate(asset.createdAt)),
          _kv('수정일', _fmtDate(asset.updatedAt)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _openInfoEditor(context, asset),
                icon: const Icon(Icons.edit),
                label: const Text('정보 수정'),
              ),
              if (hasLoc)
                FilledButton.icon(
                  onPressed: () async {
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

  Widget _kv(String k, String? v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v ?? '')),
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

  Future<void> _openInfoEditor(BuildContext context, Asset asset) async {
    await showDialog(
      context: context,
      builder: (_) => _AssetInfoDialog(asset: asset),
    );
  }
}

class _AssetInfoDialog extends StatefulWidget {
  const _AssetInfoDialog({required this.asset});
  final Asset asset;

  @override
  State<_AssetInfoDialog> createState() => _AssetInfoDialogState();
}

class _AssetInfoDialogState extends State<_AssetInfoDialog> {
  late final TextEditingController code;
  late final TextEditingController name;
  late final TextEditingController category;
  late final TextEditingController serial;
  late final TextEditingController model;
  late final TextEditingController vendor;
  late final TextEditingController building;
  late final TextEditingController floor;
  late final TextEditingController memberName;
  late final TextEditingController network;
  late final TextEditingController pCheck;
  late final TextEditingController confirm;
  late final TextEditingController normal;
  late final TextEditingController oa;
  late final TextEditingController mac;

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    code = TextEditingController(text: a.code);
    name = TextEditingController(text: a.name);
    category = TextEditingController(text: a.category);
    serial = TextEditingController(text: a.serialNumber);
    model = TextEditingController(text: a.modelName);
    vendor = TextEditingController(text: a.vendor);
    building = TextEditingController(text: a.building ?? '');
    floor = TextEditingController(text: a.floor ?? '');
    memberName = TextEditingController(text: a.memberName ?? '');
    network = TextEditingController(text: a.network ?? '');
    pCheck = TextEditingController(text: _fmtDate(a.physicalCheckDate));
    confirm = TextEditingController(text: _fmtDate(a.confirmationDate));
    normal = TextEditingController(text: a.normalComment ?? '');
    oa = TextEditingController(text: a.oaComment ?? '');
    mac = TextEditingController(text: a.macAddress ?? '');
  }

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    category.dispose();
    serial.dispose();
    model.dispose();
    vendor.dispose();
    building.dispose();
    floor.dispose();
    memberName.dispose();
    network.dispose();
    pCheck.dispose();
    confirm.dispose();
    normal.dispose();
    oa.dispose();
    mac.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String s) => s.isEmpty ? null : DateTime.tryParse(s);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('자산 정보 수정'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: '자산명')),
              TextField(controller: code, decoration: const InputDecoration(labelText: '코드')),
              TextField(controller: category, decoration: const InputDecoration(labelText: '분류')),
              TextField(controller: serial, decoration: const InputDecoration(labelText: '시리얼번호')),
              TextField(controller: model, decoration: const InputDecoration(labelText: '모델명')),
              TextField(controller: vendor, decoration: const InputDecoration(labelText: '제조사')),
              TextField(controller: building, decoration: const InputDecoration(labelText: '건물')),
              TextField(controller: floor, decoration: const InputDecoration(labelText: '층')),
              TextField(controller: memberName, decoration: const InputDecoration(labelText: '담당자')),
              TextField(controller: network, decoration: const InputDecoration(labelText: '망')),
              TextField(controller: pCheck, decoration: const InputDecoration(labelText: '실사일(YYYY-MM-DD)')),
              TextField(controller: confirm, decoration: const InputDecoration(labelText: '확정일(YYYY-MM-DD)')),
              TextField(controller: normal, decoration: const InputDecoration(labelText: '일반비고')),
              TextField(controller: oa, decoration: const InputDecoration(labelText: 'OA비고')),
              TextField(controller: mac, decoration: const InputDecoration(labelText: 'MAC 주소')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () {
            final updated = widget.asset.copyWith(
              name: name.text,
              code: code.text,
              category: category.text,
              serialNumber: serial.text,
              modelName: model.text,
              vendor: vendor.text,
              building: building.text.isEmpty ? null : building.text,
              floor: floor.text.isEmpty ? null : floor.text,
              memberName: memberName.text.isEmpty ? null : memberName.text,
              network: network.text.isEmpty ? null : network.text,
              physicalCheckDate: _parseDate(pCheck.text),
              confirmationDate: _parseDate(confirm.text),
              normalComment: normal.text.isEmpty ? null : normal.text,
              oaComment: oa.text.isEmpty ? null : oa.text,
              macAddress: mac.text.isEmpty ? null : mac.text,
            );
            context.read<AssetProvider>().updateAsset(updated);
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
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
