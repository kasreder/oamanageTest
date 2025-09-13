import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/scan_provider.dart';
import 'package:go_router/go_router.dart';

/// 전역 하단에 최근 스캔 결과를 고정 표시해주는 푸터
class ScannedFooter extends StatelessWidget {
  const ScannedFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final code = scan.lastCode;

    return Material(
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/home/scan'), // ✅ 네비 유지되는 스캔 경로
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR/바코드 스캔하기'),
            ),
          ],
        ),
      ),
    );
  }

  // String _fmtTime(DateTime? dt) {
  //   if (dt == null) return '';
  //   final hh = dt.hour.toString().padLeft(2, '0');
  //   final mm = dt.minute.toString().padLeft(2, '0');
  //   final ss = dt.second.toString().padLeft(2, '0');
  //   return '$hh:$mm:$ss';
  // }
}
