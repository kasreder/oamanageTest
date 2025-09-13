import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import '../../provider/list_provider.dart';

/// StatefulShellRoute로부터 제공되는 navigationShell을 감싼 레이아웃
/// - 화면 폭 < 450 : 하단 NavigationBar
/// - 화면 폭 >= 450 : 좌측 NavigationRail
class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index, BuildContext context) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);

    // 탭 전환 후 게시판 데이터 fetch (예: 조회수/카운트업 등)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final boardProvider = Provider.of<ViewCountProvider>(context, listen: false);
      switch (index) {
        case 0: break; // 홈
        case 1: boardProvider.fetchPostDataFromAPI('asset'); break;
        case 2: boardProvider.fetchPostDataFromAPI('free'); break;
        case 3: boardProvider.fetchPostDataFromAPI('record'); break;
        case 4: boardProvider.fetchPostDataFromAPI('drawing'); break;
        case 5: break; // 설정
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      /// 폭 좁은 경우: 하단 바
      if (constraints.maxWidth < 450) {
        return ScaffoldWithNavigationBar(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _goBranch(index, context),
        );
      } else {
        /// 폭 넓은 경우: 좌측 레일
        return FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 100)), // go_router 안정화 대기
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return ScaffoldWithNavigationRail(
              body: navigationShell,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => _goBranch(index, context),
            );
          },
        );
      }
    });
  }
}

/// 하단 네비게이션 바
class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        height: 44,
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(label: '홈',   icon: Icon(UniconsLine.home)),
          NavigationDestination(label: '자산', icon: Icon(UniconsLine.database)),
          NavigationDestination(label: '자유', icon: Icon(UniconsLine.comment_alt_dots)),
          NavigationDestination(label: '기록', icon: Icon(UniconsLine.flask)),
          NavigationDestination(label: '도면', icon: Icon(UniconsLine.building)),
          NavigationDestination(label: '설정', icon: Icon(UniconsLine.user_circle)),
        ],
        onDestinationSelected: onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
    );
  }
}

/// 좌측 네비게이션 레일
class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.none,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(label: Text('Home'),    icon: Icon(UniconsLine.home)),
              NavigationRailDestination(label: Text('Asset'),   icon: Icon(UniconsLine.database)),
              NavigationRailDestination(label: Text('Free'),    icon: Icon(UniconsLine.comment_alt_dots)),
              NavigationRailDestination(label: Text('Record'),  icon: Icon(UniconsLine.flask)),
              NavigationRailDestination(label: Text('Drawing'), icon: Icon(UniconsLine.building)),
              NavigationRailDestination(label: Text('Info'),    icon: Icon(UniconsLine.user_circle)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body), // 본문
        ],
      ),
    );
  }
}
