// lib/view/screen/asset_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/asset_provider.dart';
import 'package:go_router/go_router.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final _search = TextEditingController();
  String _keyword = '';
  String _category = '전체';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AssetProvider>();
    final all = prov.items;

    // 카테고리 목록 만들기
    final categories = <String>{'전체', ...all.map((e) => e.category)};
    // 필터링
    final filtered = all.where((a) {
      final okCat = _category == '전체' ? true : a.category == _category;
      final okKey = _keyword.isEmpty ? true : (a.name.toLowerCase().contains(_keyword) || a.code.toLowerCase().contains(_keyword));
      return okCat && okKey;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 상단 툴바
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: '자산명/코드 검색',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (v) => setState(() => _keyword = v.trim().toLowerCase()),
                ),
              ),
              DropdownButton<String>(
                value: _category,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text('분류: $c'))).toList(),
                onChanged: (v) => setState(() => _category = v ?? '전체'),
                underline: const SizedBox.shrink(),
              ),
              Text('총 ${filtered.length}개'),
            ],
          ),
          const SizedBox(height: 12),

          // 목록
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('자산이 없습니다.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      final hasLoc = a.locationRow != null && a.locationCol != null;
                      final locText = hasLoc
                          ? '위치: ${a.building ?? ''}, ${a.floor ?? ''} (${a.locationRow}, ${a.locationCol})'
                          : '위치: 미지정';
                      return ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text(a.name),
                        subtitle: Text('코드: ${a.code}  ·  분류: ${a.category}  ·  $locText'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // 상세로 이동: /asset/:id (app_router에 이미 정의)
                          context.push('/asset/${a.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
