// File Path: lib/main.dart
// Features:
// - main 함수 (13~15행): OAManagerApp을 실행합니다.
// - OAManagerApp.build (21~55행): Provider를 초기화하고 MaterialApp.router를 구성합니다.
// - addPostFrameCallback (33~41행): 자산 위치 정보를 DrawingProvider와 동기화합니다.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'route/app_router.dart';
import 'provider/drawing_provider.dart';
import 'provider/asset_provider.dart';
import 'provider/asset_verification_provider.dart';
import 'provider/list_provider.dart';
import 'provider/scan_provider.dart';

void main() {
  runApp(const OAManagerApp());
}

class OAManagerApp extends StatelessWidget {
  const OAManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => AssetVerificationProvider()),
        // 네비게이션 전환 시 게시판별 카운트를 갱신하는 ViewCountProvider
        ChangeNotifierProvider(create: (_) => ViewCountProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
      ],
      child: Builder(
        builder: (context) {
          // ✅ 앱 시작 시: 자산에 저장된 위치를 도면에 1회 동기화
          final dp = context.read<DrawingProvider>();
          final ap = context.read<AssetProvider>();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            for (final a in ap.items) {
              if (a.locationDrawingId != null && a.locationRow != null && a.locationCol != null) {
                await dp.addAssetToCell(
                  id: a.locationDrawingId!, row: a.locationRow!, col: a.locationCol!, assetId: a.id,
                );
              }
            }
          });

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'OA Manager',
            routerConfig: appRouter,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff7e57c2)),
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}
