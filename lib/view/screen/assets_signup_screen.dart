import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/asset_provider.dart';

class AssetsSignUpScreen extends StatefulWidget {
  const AssetsSignUpScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<AssetsSignUpScreen> createState() => _AssetsSignUpScreenState();
}

class _AssetsSignUpScreenState extends State<AssetsSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _serial = TextEditingController();
  final _modelName = TextEditingController();
  final _vendor = TextEditingController();
  final _network = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _memberName = TextEditingController();
  final _normalComment = TextEditingController();
  final _oaComment = TextEditingController();
  final _macAddress = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _category.dispose();
    _serial.dispose();
    _modelName.dispose();
    _vendor.dispose();
    _network.dispose();
    _building.dispose();
    _floor.dispose();
    _memberName.dispose();
    _normalComment.dispose();
    _oaComment.dispose();
    _macAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('자산 등록', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('바코드 스캔 후 신규 자산을 등록합니다. 모든 필드를 가능한 정확히 입력해주세요.'),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _code,
              label: '자산 코드',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '자산 코드를 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _name,
              label: '자산명',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '자산명을 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _category,
              label: '자산 분류',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '자산 분류를 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _serial,
              label: 'S/N',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '시리얼 번호를 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _modelName,
              label: '모델명',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '모델명을 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _vendor,
              label: '제조사/공급사',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제조사 또는 공급사를 입력해주세요.';
                }
                return null;
              },
            ),
            _buildTextField(controller: _network, label: '네트워크 구분'),
            _buildTextField(controller: _building, label: '설치 건물'),
            _buildTextField(controller: _floor, label: '설치 층'),
            _buildTextField(controller: _memberName, label: '담당자/소유자'),
            _buildTextField(controller: _normalComment, label: '일반 비고', maxLines: 3),
            _buildTextField(controller: _oaComment, label: 'OA 비고', maxLines: 3),
            _buildTextField(controller: _macAddress, label: 'MAC 주소'),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('자산 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<AssetProvider>();
    final code = _code.text.trim();
    if (provider.getByCode(code) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 등록된 코드입니다: $code')),
      );
      return;
    }

    provider.createAsset(
      code: code,
      name: _name.text.trim(),
      category: _category.text.trim(),
      serialNumber: _serial.text.trim(),
      modelName: _modelName.text.trim(),
      vendor: _vendor.text.trim(),
      network: _network.text.trim().isEmpty ? null : _network.text.trim(),
      building: _building.text.trim().isEmpty ? null : _building.text.trim(),
      floor: _floor.text.trim().isEmpty ? null : _floor.text.trim(),
      memberName: _memberName.text.trim().isEmpty ? null : _memberName.text.trim(),
      normalComment:
          _normalComment.text.trim().isEmpty ? null : _normalComment.text.trim(),
      oaComment: _oaComment.text.trim().isEmpty ? null : _oaComment.text.trim(),
      macAddress: _macAddress.text.trim().isEmpty ? null : _macAddress.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('자산이 등록되었습니다. (코드: $code)')),
    );
    _formKey.currentState!.reset();
    _name.clear();
    _category.clear();
    _serial.clear();
    _modelName.clear();
    _vendor.clear();
    _network.clear();
    _building.clear();
    _floor.clear();
    _memberName.clear();
    _normalComment.clear();
    _oaComment.clear();
    _macAddress.clear();
  }
}
