import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/asset_provider.dart';
import '../../provider/asset_verification_provider.dart';

class AssetVerificationScreen extends StatefulWidget {
  const AssetVerificationScreen({super.key, required this.assetId});

  final String assetId;

  @override
  State<AssetVerificationScreen> createState() => _AssetVerificationScreenState();
}

class _AssetVerificationScreenState extends State<AssetVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assetNumber = TextEditingController();
  final _ownerName = TextEditingController();
  final _serialNumber = TextEditingController();
  final _assetCategory = TextEditingController();
  final _usageType = TextEditingController();
  final _modelName = TextEditingController();
  final _team = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _networkType = TextEditingController();
  final _usageDetail = TextEditingController();
  final _signature = TextEditingController();

  DateTime? _lastVerifiedAt;
  bool _initialized = false;

  @override
  void dispose() {
    _assetNumber.dispose();
    _ownerName.dispose();
    _serialNumber.dispose();
    _assetCategory.dispose();
    _usageType.dispose();
    _modelName.dispose();
    _team.dispose();
    _building.dispose();
    _floor.dispose();
    _networkType.dispose();
    _usageDetail.dispose();
    _signature.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final asset = context.read<AssetProvider>().getById(widget.assetId);
    final verification =
        context.read<AssetVerificationProvider>().getByAssetId(widget.assetId);
    if (asset != null) {
      _assetNumber.text = asset.code;
      _ownerName.text = asset.memberName ?? '';
      _serialNumber.text = asset.serialNumber;
      _assetCategory.text = asset.category;
      _modelName.text = asset.modelName;
      _building.text = asset.building ?? '';
      _floor.text = asset.floor ?? '';
      _networkType.text = asset.network ?? '';
    }
    if (verification != null) {
      _usageType.text = verification.usageType;
      _team.text = verification.team;
      _usageDetail.text = verification.usageDetail;
      _signature.text = verification.signature;
      _lastVerifiedAt = verification.verifiedAt;
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final asset = context.watch<AssetProvider>().getById(widget.assetId);
    if (asset == null) {
      return const Center(child: Text('자산 정보를 찾을 수 없습니다.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('실물 확인', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('자산코드 ${asset.code}에 대한 실물 확인 및 최종 사용자 서명을 수집합니다.'),
            if (_lastVerifiedAt != null) ...[
              const SizedBox(height: 8),
              Text('최근 확인일: ${_formatDate(_lastVerifiedAt!)}',
                  style: const TextStyle(color: Colors.green)),
            ],
            const SizedBox(height: 24),
            _buildTable(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.fact_check),
                label: const Text('실물 확인 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _tableRow('자산번호', _assetNumber, readOnly: true),
        _tableRow('소유자명', _ownerName),
        _tableRow('S/N', _serialNumber, readOnly: true),
        _tableRow('자산종류', _assetCategory, readOnly: true),
        _tableRow('사용용도(개인/공용)', _usageType,
            hintText: '예) 개인', validator: _requiredValidator),
        _tableRow('모델명', _modelName, readOnly: true),
        _tableRow('팀', _team, hintText: '예) 생산기술팀'),
        _tableRow('설치건물', _building),
        _tableRow('설치 층', _floor),
        _tableRow('네트워크구분', _networkType),
        _tableRow('용도상세', _usageDetail,
            hintText: '예) 회의실 화상회의 장비', validator: _requiredValidator),
        _tableRow('최종 사용자 서명', _signature,
            hintText: '서명 또는 이름을 입력해주세요', validator: _requiredValidator),
      ],
    );
  }

  TableRow _tableRow(String label, TextEditingController controller,
      {bool readOnly = false,
      String? hintText,
      String? Function(String?)? validator}) {
    return TableRow(
      children: [
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목입니다.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final verificationProvider = context.read<AssetVerificationProvider>();
    verificationProvider.saveVerification(
      assetId: widget.assetId,
      assetNumber: _assetNumber.text.trim(),
      ownerName: _ownerName.text.trim(),
      serialNumber: _serialNumber.text.trim(),
      assetCategory: _assetCategory.text.trim(),
      usageType: _usageType.text.trim(),
      modelName: _modelName.text.trim(),
      team: _team.text.trim(),
      building: _building.text.trim(),
      floor: _floor.text.trim(),
      networkType: _networkType.text.trim(),
      usageDetail: _usageDetail.text.trim(),
      signature: _signature.text.trim(),
    );
    setState(() {
      _lastVerifiedAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('실물 확인 정보가 저장되었습니다.')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
