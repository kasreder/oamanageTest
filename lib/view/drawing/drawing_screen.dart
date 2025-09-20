// File Path: lib/view/drawing/drawing_screen.dart
// Features:
// - DrawingScreen.build (22~88행): DrawingProvider에서 도면 목록을 읽어 카드 리스트와 범례를 렌더링합니다.
// - 열기 버튼 onPressed (65~69행): 도면 이미지를 로드한 뒤 '/drawing/:id/map' 라우트로 이동합니다.
// - _Legend.build (97~116행): 배경 여부를 나타내는 간단한 범례 UI를 구성합니다.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../provider/drawing_provider.dart';
import '../../model/drawing.dart';
import '../../util/drawing_image_loader.dart';

/// 도면 목록 화면
/// - "열기" 버튼을 누르면:
///   1) lib/asset/locationmap/<파일명> 에서 이미지를 읽어와 해당 도면의 배경으로 설정
///   2) 맵 화면(/drawing/:id/map)으로 이동 → 배경 + 격자 표시
class DrawingScreen extends StatelessWidget {
  const DrawingScreen({super.key});

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
                      // 이미지 바이트가 로드되지 않았더라도 파일명이 지정되어 있으면 배경이 있는 것으로 간주
                      final hasBg = d.imageName != null || kDrawingImageFiles[d.id] != null;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasBg ? Colors.green : Colors.grey.shade300,
                          child: Icon(
                            hasBg ? Icons.image : Icons.image_not_supported,
                            color: hasBg ? Colors.white : Colors.black38,
                          ),
                        ),
                        title: Text('${d.building} · ${d.floor} · ${d.title}'),
                        subtitle: Text('격자: ${d.gridRows} x ${d.gridCols}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text('열기'), // 배경 적용 후 맵 이동
                              onPressed: () async {
                                await loadDrawingImageIfNeeded(dp, d);
                                if (context.mounted) {
                                  context.push('/drawing/${d.id}/map');
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
