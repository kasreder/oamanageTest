// lib/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/widget/navigation.dart';
import '../view/widget/drawer.dart';
import '../view/widget/scanned_footer.dart';

import '../view/screen/home_screen.dart';
import '../view/screen/free_screen.dart';
import '../view/screen/record_screen.dart';
import '../view/screen/settings_screen.dart';
import '../view/screen/login_screen.dart';
import '../view/screen/member_screen.dart';
import '../view/screen/scan_screen.dart';

// 자산(게시판)
import '../view/screen/asset_list_screen.dart';
import '../view/screen/asset_detail_screen.dart';
import '../view/screen/asset_edit_screen.dart';

// 도면
import '../view/drawing/drawing_screen.dart';
import '../view/drawing/drawing_map_screen.dart'; // ✅ 추가

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BaseDrawer(),
      body: body,
      bottomNavigationBar: const ScannedFooter(),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavKey    = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _assetNavKey   = GlobalKey<NavigatorState>(debugLabel: 'assetNav');
final _freeNavKey    = GlobalKey<NavigatorState>(debugLabel: 'freeNav');
final _recordNavKey  = GlobalKey<NavigatorState>(debugLabel: 'recordNav');
final _drawingNavKey = GlobalKey<NavigatorState>(debugLabel: 'drawingNav');
final _settingKey    = GlobalKey<NavigatorState>(debugLabel: 'settingNav');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNestedNavigation(navigationShell: navigationShell),
      branches: [
        // 0) 홈
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: HomeScreen()),
              ),
              routes: [
                GoRoute(
                  path: 'scan',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ShellScaffold(body: ScanScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 1) 자산
        StatefulShellBranch(
          navigatorKey: _assetNavKey,
          routes: [
            GoRoute(
              path: '/asset',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: AssetListScreen()),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: ShellScaffold(
                      body: AssetDetailScreen(id: state.pathParameters['id']!),
                    ),
                  ),
                ),
                GoRoute(
                  path: 'new',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ShellScaffold(body: AssetEditScreen(mode: AssetEditMode.create)),
                  ),
                ),
                GoRoute(
                  path: ':id/edit',
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: ShellScaffold(
                      body: AssetEditScreen(mode: AssetEditMode.update, id: state.pathParameters['id']),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 2) 자유
        StatefulShellBranch(
          navigatorKey: _freeNavKey,
          routes: [
            GoRoute(
              path: '/comm/free',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: FreeScreen()),
              ),
            ),
          ],
        ),
        // 3) 기록
        StatefulShellBranch(
          navigatorKey: _recordNavKey,
          routes: [
            GoRoute(
              path: '/comm1/record',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: RecordScreen()),
              ),
            ),
          ],
        ),
        // 4) 도면
        StatefulShellBranch(
          navigatorKey: _drawingNavKey,
          routes: [
            GoRoute(
              path: '/drawing',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: DrawingScreen()),
              ),
              routes: [
                // ✅ 도면 전용 페이지: /drawing/:id/map
                GoRoute(
                  path: ':id/map',
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: ShellScaffold(
                      body: DrawingMapScreen(drawingId: state.pathParameters['id']!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 5) 설정
        StatefulShellBranch(
          navigatorKey: _settingKey,
          routes: [
            GoRoute(
              path: '/set',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShellScaffold(body: SettingsScreen()),
              ),
            ),
          ],
        ),
      ],
    ),
    // 공용
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/member', builder: (context, state) => const MemberScreen()),
  ],
);
