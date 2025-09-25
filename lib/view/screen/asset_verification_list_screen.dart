// File Path: lib/view/screen/asset_verification_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/asset.dart';
import '../../provider/asset_provider.dart';
import '../../provider/asset_verification_provider.dart';

enum _VerificationStatus { unverified, verified }

class AssetVerificationListScreen extends StatefulWidget {
  const AssetVerificationListScreen({super.key});

  @override
  State<AssetVerificationListScreen> createState() =>
      _AssetVerificationListScreenState();
}

class _AssetVerificationListScreenState
    extends State<AssetVerificationListScreen> {
  _VerificationStatus _status = _VerificationStatus.unverified;
  String? _selectedCategory;
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

    final categories = {
      for (final asset in assets) asset.category,
    }.toList()
      ..sort();

    final query = _searchController.text.trim().toLowerCase();

    final filteredAssets = assets.where((asset) {
      final isVerified = verifiedAssetIds.contains(asset.id);
      if (_status == _VerificationStatus.unverified && isVerified) {
        return false;
      }
      if (_status == _VerificationStatus.verified && !isVerified) {
        return false;
      }

      if (_selectedCategory != null && asset.category != _selectedCategory) {
        return false;
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
                width: 200,
                child: _buildCategoryDropdown(categories),
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

  Widget _buildCategoryDropdown(List<String> categories) {
    final options = ['전체', ...categories];
    final value = _selectedCategory ?? '전체';
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: '분류',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: options
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue == null || newValue == '전체'
              ? null
              : newValue;
        });
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
}
