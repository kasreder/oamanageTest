// File Path: lib/view/screen/asset_verification_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/asset.dart';
import '../../provider/asset_provider.dart';
import '../../provider/asset_verification_provider.dart';

enum _VerificationStatus { unverified, verified }

enum _OrganizationLevel { headquarters, department, team }

class _DropdownSpecialKeys {
  static const String all = '__all__';
  static const String unassigned = '__unassigned__';
}

class _DropdownOption {
  const _DropdownOption(this.key, this.label);

  final String key;
  final String label;
}

class _OrganizationInfo {
  const _OrganizationInfo({this.headquarters, this.department, this.team});

  final String? headquarters;
  final String? department;
  final String? team;
}

class AssetVerificationListScreen extends StatefulWidget {
  const AssetVerificationListScreen({super.key});

  @override
  State<AssetVerificationListScreen> createState() =>
      _AssetVerificationListScreenState();
}

class _AssetVerificationListScreenState
    extends State<AssetVerificationListScreen> {
  _VerificationStatus _status = _VerificationStatus.unverified;
  String _selectedCategoryKey = _DropdownSpecialKeys.all;
  _OrganizationLevel _organizationLevel = _OrganizationLevel.team;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = context.watch<AssetProvider>().items;
    final verificationProvider = context.watch<AssetVerificationProvider>();
    final verifiedAssetIds =
        verificationProvider.items.map((e) => e.assetId).toSet();

    final verificationMap = {
      for (final verification in verificationProvider.items)
        verification.assetId: verification,
    };

    final organizationInfos = <String, _OrganizationInfo>{
      for (final asset in assets)
        asset.id: _extractOrganizationInfo(verificationMap[asset.id]?.team),
    };

    final categoryOptions = _buildCategoryOptions(
      organizationInfos.values,
      _organizationLevel,
    );
    final categoryKeys = categoryOptions.map((option) => option.key).toSet();
    final selectedCategoryKey = categoryKeys.contains(_selectedCategoryKey)
        ? _selectedCategoryKey
        : _DropdownSpecialKeys.all;

    final query = _searchController.text.trim().toLowerCase();

    final filteredAssets = assets.where((asset) {
      final isVerified = verifiedAssetIds.contains(asset.id);
      if (_status == _VerificationStatus.unverified && isVerified) {
        return false;
      }
      if (_status == _VerificationStatus.verified && !isVerified) {
        return false;
      }

      final organizationValue = _organizationValueForLevel(
        organizationInfos[asset.id],
        _organizationLevel,
      );

      if (selectedCategoryKey == _DropdownSpecialKeys.unassigned) {
        if (organizationValue != null && organizationValue.trim().isNotEmpty) {
          return false;
        }
      } else if (selectedCategoryKey != _DropdownSpecialKeys.all) {
        if (organizationValue != selectedCategoryKey) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final haystack = [
          asset.code,
          asset.name,
          asset.memberName ?? '',
          asset.serialNumber,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('실사 인증 장비 목록',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildStatusSelector(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: _buildOrganizationLevelSelector(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildCategoryDropdown(
                  categoryOptions,
                  selectedCategoryKey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredAssets.isEmpty
                ? _buildEmptyState()
                : _buildAssetList(
                    filteredAssets, verificationProvider, verifiedAssetIds),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return SegmentedButton<_VerificationStatus>(
      segments: const [
        ButtonSegment(
          value: _VerificationStatus.unverified,
          label: Text('미인증 장비'),
          icon: Icon(Icons.report_problem_outlined),
        ),
        ButtonSegment(
          value: _VerificationStatus.verified,
          label: Text('인증 완료 장비'),
          icon: Icon(Icons.verified_outlined),
        ),
      ],
      selected: <_VerificationStatus>{_status},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          setState(() {
            _status = selection.first;
          });
        }
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: '검색',
        hintText: '자산명, 자산코드 또는 담당자명으로 검색',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildCategoryDropdown(
    List<_DropdownOption> options,
    String selectedKey,
  ) {
    final isDisabled = options.length <= 1;
    return DropdownButtonFormField<String>(
      value: selectedKey,
      decoration: const InputDecoration(
        labelText: '분류',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option.key,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: isDisabled
          ? null
          : (newValue) {
              setState(() {
                _selectedCategoryKey =
                    newValue ?? _DropdownSpecialKeys.all;
              });
            },
    );
  }

  Widget _buildOrganizationLevelSelector() {
    return DropdownButtonFormField<_OrganizationLevel>(
      value: _organizationLevel,
      decoration: const InputDecoration(
        labelText: '분류 기준',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: _OrganizationLevel.values
          .map(
            (level) => DropdownMenuItem(
              value: level,
              child: Text(_labelForOrganizationLevel(level)),
            ),
          )
          .toList(),
      onChanged: (newLevel) {
        if (newLevel != null) {
          setState(() {
            _organizationLevel = newLevel;
            _selectedCategoryKey = _DropdownSpecialKeys.all;
          });
        }
      },
    );
  }

  Widget _buildAssetList(
    List<Asset> assets,
    AssetVerificationProvider verificationProvider,
    Set<String> verifiedAssetIds,
  ) {
    return ListView.separated(
      itemCount: assets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        final verification = verificationProvider.getByAssetId(asset.id);
        final isVerified = verifiedAssetIds.contains(asset.id);
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            onTap: () =>
                context.push('/notice/assetVerification/${asset.id}'),
            title: Text('${asset.name} (${asset.code})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('분류: ${asset.category}'),
                if ((asset.memberName ?? '').isNotEmpty)
                  Text('담당자: ${asset.memberName}'),
                if (isVerified && verification?.verifiedAt != null)
                  Text('인증일: ${_formatDate(verification!.verifiedAt!)}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isVerified ? Icons.verified : Icons.report_problem_outlined,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 4),
                Text(isVerified ? '인증완료' : '미인증',
                    style: TextStyle(
                      color: isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _status == _VerificationStatus.verified
                ? Icons.verified_user_outlined
                : Icons.inventory_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _status == _VerificationStatus.verified
                ? '인증 완료된 장비가 없습니다.'
                : '미인증 장비가 없습니다.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<_DropdownOption> _buildCategoryOptions(
    Iterable<_OrganizationInfo> infos,
    _OrganizationLevel level,
  ) {
    final labels = <String>{};
    var hasUnassigned = false;

    for (final info in infos) {
      final value = _organizationValueForLevel(info, level);
      if (value == null || value.trim().isEmpty) {
        hasUnassigned = true;
      } else {
        labels.add(value);
      }
    }

    final sortedLabels = labels.toList()..sort();
    final options = <_DropdownOption>[
      const _DropdownOption(_DropdownSpecialKeys.all, '전체'),
      ...sortedLabels.map((label) => _DropdownOption(label, label)),
    ];

    if (hasUnassigned) {
      options.add(const _DropdownOption(_DropdownSpecialKeys.unassigned, '미지정'));
    }

    return options;
  }

  _OrganizationInfo _extractOrganizationInfo(String? rawTeam) {
    if (rawTeam == null || rawTeam.trim().isEmpty) {
      return const _OrganizationInfo();
    }

    final normalized = rawTeam
        .replaceAll(RegExp(r'[>/\\|]'), ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    String? headquarters;
    String? department;
    String? team;

    for (final part in normalized) {
      final value = part.trim();
      if (value.isEmpty) continue;
      if (value.endsWith('본부') && headquarters == null) {
        headquarters = value;
      } else if (value.endsWith('실') && department == null) {
        department = value;
      } else if (value.endsWith('팀') && team == null) {
        team = value;
      }
    }

    if (team == null && normalized.isNotEmpty) {
      team = normalized.last;
    }
    if (department == null && normalized.length >= 2) {
      department = normalized[normalized.length - 2];
    }
    if (headquarters == null && normalized.length >= 3) {
      headquarters = normalized[normalized.length - 3];
    }

    return _OrganizationInfo(
      headquarters: headquarters,
      department: department,
      team: team,
    );
  }

  String? _organizationValueForLevel(
    _OrganizationInfo? info,
    _OrganizationLevel level,
  ) {
    if (info == null) return null;
    switch (level) {
      case _OrganizationLevel.headquarters:
        return info.headquarters;
      case _OrganizationLevel.department:
        return info.department;
      case _OrganizationLevel.team:
        return info.team;
    }
  }

  String _labelForOrganizationLevel(_OrganizationLevel level) {
    switch (level) {
      case _OrganizationLevel.headquarters:
        return '본부';
      case _OrganizationLevel.department:
        return '실';
      case _OrganizationLevel.team:
        return '팀';
    }
  }
}
