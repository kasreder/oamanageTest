import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/scan_provider.dart';

/// 홈 화면: 스캔 이동 버튼 + 최근 기록
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('COSMOSX OA Manager', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/home/scan'), // ✅ 네비 유지되는 스캔 경로
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('QR/바코드 스캔하기'),
          ),
          const SizedBox(height: 24),
          Text('최근 스캔 기록', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (scan.history.isEmpty)
            const Text('아직 스캔 기록이 없습니다.')
          else
            ...scan.history.take(10).map((e) => ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
            )),
        ],
      ),
    );
  }
}
