// lib/view/drawing/drawing_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../provider/drawing_provider.dart';
import '../../model/drawing.dart';

/// 도면 목록 화면
/// - "열기" 버튼을 누르면:
///   1) lib/asset/locationmap/<파일명> 에서 이미지를 읽어와 해당 도면의 배경으로 설정
///   2) 맵 화면(/drawing/:id/map)으로 이동 → 배경 + 격자 표시
class DrawingScreen extends StatelessWidget {
  const DrawingScreen({super.key});

  // 👉 현재 요구대로 고정 파일명 사용. 나중에 항목별로 다르게 하고 싶으면
  //    d.building/floor/title 등을 조합해서 파일명을 만들면 된다.
  static const String kMapImageFileName = 'conco_11F_A.jpg';
  static const String kMapImageAssetPath = 'lib/asset/locationmap/';

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DrawingProvider>();
    final items = dp.items;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('도면 목록', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              const SizedBox(width: 8),
              const _Legend(),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('등록된 도면이 없습니다.'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final d = items[i];
                      final hasBg = d.imageBytes != null && d.imageBytes!.isNotEmpty;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasBg ? Colors.green : Colors.grey.shade300,
                          child: Icon(hasBg ? Icons.image : Icons.image_not_supported, color: hasBg ? Colors.white : Colors.black38),
                        ),
                        title: Text('${d.building} · ${d.floor} · ${d.title}'),
                        subtitle: Text('격자: ${d.gridRows} x ${d.gridCols}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text('열기'),// (열기 버튼) 배경 적용 후 맵 이동
                              onPressed: () async {
                                await _applyBackgroundFromAsset(context, d);
                                if (context.mounted) {
                                  context.push('/drawing/${d.id}/map'); // ✅ pushNamed → push (go_router)
                                }
                              },
                            ),
                            if (hasBg)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.map),
                                label: const Text('맵 보기'),// (맵 보기 버튼)
                                onPressed: () {
                                  context.push('/drawing/${d.id}/map'); // ✅ pushNamed → push (go_router)
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// lib/asset/locationmap/<kMapImageFileName> 를 읽어와서
  /// DrawingProvider에 이미지 바이트를 설정한다.
  Future<void> _applyBackgroundFromAsset(BuildContext context, Drawing d) async {
    final dp = context.read<DrawingProvider>();

    try {
      final String assetPath = '$kMapImageAssetPath$kMapImageFileName';

      // assets 에 등록된 파일에서 바이트 로드
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Provider에 이미지 적용 (아래 메서드명은 기존 구현에 맞춰 사용)
      // - 만약 setImageBytes가 없다면, DrawingProvider에 해당 메서드를 추가해 주세요.
      //   예) Future<void> setImageBytes({required String id, required Uint8List bytes})
      await dp.setImageBytes(id: d.id, bytes: bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('배경 이미지 로드 실패: $e')),
        );
      }
    }
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            const _Dot(color: Colors.green),
            const SizedBox(width: 6),
            Text('배경 설정됨', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _Dot(color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text('배경 없음', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
