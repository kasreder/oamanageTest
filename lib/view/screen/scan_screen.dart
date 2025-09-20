// File Path: lib/view/screen/scan_screen.dart
// Features:
// - _ScanScreenState.build (58~188행): 카메라 프리뷰, 마스킹, 컨트롤 오버레이, 최근 스캔 정보를 포함한 스캔 UI를 구성합니다.
// - _onWillPop (40~43행): 하드웨어 뒤로가기 입력 시 스캐너를 정지하고 현재 라우트를 종료합니다.
// - MobileScanner.onDetect (85~101행): 감지한 바코드를 ScanProvider.record로 저장하고 재감지를 제어합니다.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../provider/scan_provider.dart';

/// 스캔 화면:
/// - 중앙 카메라 박스만 보이고, 그 외 영역은 흰색 마스킹
/// - 상단 좌/우에 뒤로가기, 플래시, 카메라 전환, 일시정지 버튼 오버레이
/// - 하단 중앙에 "신규/재등록 + 코드" 오버레이 표시
/// - 라우터: /home/scan (홈 브랜치 하위라 네비게이션이 항상 보임)
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _paused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 시스템 뒤로가기(안드로이드 하드웨어 버튼) 대응
  Future<bool> _onWillPop() async {
    try { await _controller.stop(); } catch (_) {}
    if (mounted) context.pop();
    return false; // 기본 pop 차단(우리가 처리)
  }

  /// 컨트롤 버튼
  void _togglePause() {
    if (_paused) {
      _controller.start();
    } else {
      _controller.stop();
    }
    setState(() => _paused = !_paused);
  }
  void _toggleTorch() => _controller.toggleTorch();
  void _switchCamera() => _controller.switchCamera();

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final code = scan.lastCode;
    final isRe = scan.isReregister;

    // 중앙 카메라 박스 크기 (필요시 조정)
    const double boxSize = 280;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // 중앙 박스 좌표
          final left = (w - boxSize) / 2;
          final top  = (h - boxSize) / 2;

          return Stack(
            children: [
              // 기본 배경을 흰색으로
              Container(color: Colors.white),

              // 카메라 프리뷰(전체 채우기)
              Positioned.fill(
                child: MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;
                    final raw = barcodes.first.rawValue;
                    if (raw == null || raw.isEmpty) return;

                    // Provider에 기록 -> 재등록 여부/시간/최근값 업데이트
                    context.read<ScanProvider>().record(raw);

                    // 연속 감지 과도 방지 (잠깐 멈춤 후 재시작)
                    _controller.stop();
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted && !_paused) _controller.start();
                    });
                  },
                  errorBuilder: (context, error, child) {
                    return Center(child: Text('카메라 초기화 실패: $error'));
                  },
                ),
              ),

              // ====== 흰색 마스킹: 카메라 박스 바깥은 전부 흰색으로 덮기 ======
              // 상단 마스크
              Positioned(left: 0, right: 0, top: 0, height: top,
                  child: Container(color: Colors.white)),
              // 하단 마스크
              Positioned(left: 0, right: 0, top: top + boxSize, bottom: 0,
                  child: Container(color: Colors.white)),
              // 좌측 마스크
              Positioned(left: 0, top: top, width: left, height: boxSize,
                  child: Container(color: Colors.white)),
              // 우측 마스크
              Positioned(left: left + boxSize, right: 0, top: top, height: boxSize,
                  child: Container(color: Colors.white)),

              // 중앙 조준 박스(보이는 영역)
              Positioned(
                left: left, top: top, width: boxSize, height: boxSize,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // 좌상단: 뒤로가기 버튼(오버레이)
              Positioned(
                left: 12, top: 12,
                child: _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () async {
                    try { await _controller.stop(); } catch (_) {}
                    if (mounted) context.pop();
                  },
                ),
              ),

              // 우상단: 플래시/카메라 전환/일시정지
              Positioned(
                right: 12, top: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleIconButton(icon: Icons.flash_on, onTap: _toggleTorch),
                    const SizedBox(width: 8),
                    _CircleIconButton(icon: Icons.cameraswitch, onTap: _switchCamera),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: _paused ? Icons.play_arrow : Icons.pause,
                      onTap: _togglePause,
                    ),
                  ],
                ),
              ),

              // 하단 중앙: 방금 읽힌 코드 오버레이 (신규/재등록 + 코드 + 시간)
              if (code != null) Positioned(
                left: 0, right: 0, bottom: 24,
                child: Center(
                  child: _CodeOverlay(
                    code: code,
                    isReregister: isRe,
                    timeText: _fmtTime(scan.lastAt),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _fmtTime(DateTime? dt) {
    if (dt == null) return '';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}

/// 동그란 흰색 아이콘 버튼 (오버레이용)
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

/// 하단 코드 표시용 칩 스타일 오버레이
class _CodeOverlay extends StatelessWidget {
  const _CodeOverlay({required this.code, required this.isReregister, required this.timeText});
  final String code;
  final bool isReregister;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final statusColor = isReregister ? Colors.orange : Colors.green;
    final statusText  = isReregister ? '재등록' : '신규';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.7)),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              code,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ),
          const SizedBox(width: 10),
          Text(timeText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
