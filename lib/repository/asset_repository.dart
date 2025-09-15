// lib/repository/asset_repository.dart
import 'dart:math';
import '../model/asset.dart';
import '../model/building_pic.dart';
import '../model/user.dart';

class AssetRepository {
  final List<Asset> _items = [];
  int _idCounter = 0; // 오름차순 순번

  AssetRepository() {
    _seed20();
  }

  // ───────────────────────────────────────────────────────────
  // Public
  List<Asset> list() => List.unmodifiable(_items);

  Asset? getById(String id) => _items.where((e) => e.id == id).firstOrNull;

  Asset create(Asset a) {
    _items.insert(0, a);
    return a;
  }

  Asset? update(Asset a) {
    final idx = _items.indexWhere((e) => e.id == a.id);
    if (idx < 0) return null;
    _items[idx] = a.copyWith(updatedAt: DateTime.now());
    return _items[idx];
  }

  /// 위치 지정/해제
  Asset? setLocation({
    required String id,
    String? drawingId,
    int? row,
    int? col,
    String? drawingFile,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    final now = DateTime.now();
    _items[idx] = _items[idx].copyWith(
      locationDrawingId: drawingId,
      locationRow: row,
      locationCol: col,
      locationDrawingFile: drawingFile,
      updatedAt: now,
    );
    return _items[idx];
  }

  // ───────────────────────────────────────────────────────────
  // Seed & Helpers

  void _seed20() {
    final rnd = Random();
    final vendors = ['Samsung', 'LG', 'Siemens', 'FANUC', 'Omron', 'Keyence', 'Bosch', 'Panasonic'];
    final models  = ['X100', 'M450', 'S2-Pro', 'VX-9', 'HF-220', 'Prime-7', 'Neo-3', 'Edge-11'];
    final cats2   = ['생산설비', 'IT장비', '품질장비', '공용비품', '안전설비'];
    final cats1   = ['모니터', '프린터', '데스크탑', '노트북', '태블릿', '스캐너', 'Test폰', '기타'];
    final networks = ['업무망', '개발망', '시스템망', '인터넷망', null];
    const buildings = buildingNames;
    const floors = floorList;
    const List<String?> bgFiles = buildingBgFiles;
    final members = [...employeeNames, null];

    // 최근 365일 내 랜덤 생성일
    DateTime _randCreated() {
      final days = rnd.nextInt(365);
      final hours = rnd.nextInt(24);
      final mins = rnd.nextInt(60);
      return DateTime.now().subtract(Duration(days: days, hours: hours, minutes: mins));
    }

    // updatedAt은 createdAt 이후 1분~60일 사이
    DateTime _randUpdatedAfter(DateTime created) {
      final addDays = rnd.nextInt(60);
      final addMins = 1 + rnd.nextInt(60 * 24);
      return created.add(Duration(days: addDays, minutes: addMins));
    }

    // 코드: 알파벳 한 글자 + 숫자 5자리 (유일)
    final usedCodes = <String>{};
    String _genCode() {
      while (true) {
        final letter = String.fromCharCode('A'.codeUnitAt(0) + rnd.nextInt(26));
        final num5   = rnd.nextInt(100000).toString().padLeft(5, '0');
        final code = '$letter$num5';
        if (!usedCodes.contains(code)) {
          usedCodes.add(code);
          return code;
        }
      }
    }

    // S/N 랜덤
    String _serial() {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      String pick(int n) => List.generate(n, (_) => chars[rnd.nextInt(chars.length)]).join();
      return '${pick(4)}-${pick(4)}-${pick(4)}';
    }

    // 오름차순 id 생성 ("1","2","3"...)
    String _nextId() {
      _idCounter += 1;
      return _idCounter.toString();
    }

    // 기본 10개 프리셋
    final presets = [
      ('프레스기 A', '생산설비'),
      ('프레스기 B', '생산설비'),
      ('컨베이어 1호', '생산설비'),
      ('스위치 24P', 'IT장비'),
      ('무선 AP-동측', 'IT장비'),
      ('마이크로미터', '품질장비'),
      ('캘리퍼스', '품질장비'),
      ('냉장고', '공용비품'),
      ('에어컨-사무동', '공용비품'),
      ('소화전 펌프', '안전설비'),
    ];

    for (final p in presets) {
      final id = _nextId();
      final code = _genCode();
      final name = p.$1;
      final cat = p.$2;
      final vendor = vendors[rnd.nextInt(vendors.length)];
      final model = models[rnd.nextInt(models.length)];
      final sn = _serial();
      final building = buildings[rnd.nextInt(buildings.length)];
      final floor = floors[rnd.nextInt(floors.length)];
      final member = members[rnd.nextInt(members.length)];
      final drawFile = bgFiles[rnd.nextInt(bgFiles.length)];
      final drawId = drawFile == null ? null : 'D${1 + rnd.nextInt(8)}';
      final row = drawFile == null ? null : rnd.nextInt(10);
      final col = drawFile == null ? null : rnd.nextInt(10);
      final network = networks[rnd.nextInt(networks.length)];
      final created = _randCreated();
      final updated = _randUpdatedAfter(created);
      final physical = _randCreated();
      final confirm = _randCreated();
      final normalC = '기본 비고 $id';
      final oaC = 'OA 비고 $id';
      String _mac() {
        String two() => rnd.nextInt(256).toRadixString(16).padLeft(2, '0');
        return List.generate(6, (_) => two()).join('-');
      }
      final mac = _mac();

      _items.add(Asset(
        id: id,
        code: code,
        name: name,
        category: cat,
        serialNumber: sn,
        modelName: model,
        vendor: vendor,
        building: building,
        floor: floor,
        memberName: member,
        network: network,
        physicalCheckDate: physical,
        confirmationDate: confirm,
        normalComment: normalC,
        oaComment: oaC,
        macAddress: mac,
        locationDrawingId: drawId,
        locationRow: row,
        locationCol: col,
        locationDrawingFile: drawFile,
        createdAt: created,
        updatedAt: updated,
      ));
    }

    // 추가 10개 랜덤 생성
    for (int i = 0; i < 10; i++) {
      final id = _nextId();
      final code = _genCode();
      final cat1 = cats1[rnd.nextInt(cats1.length)];
      final cat2 = cats2[rnd.nextInt(cats2.length)];
      final name = '$cat1-$id';
      final vendor = vendors[rnd.nextInt(vendors.length)];
      final model = models[rnd.nextInt(models.length)];
      final sn = _serial();
      final building = buildings[rnd.nextInt(buildings.length)];
      final floor = floors[rnd.nextInt(floors.length)];
      final member = members[rnd.nextInt(members.length)];
      final drawFile = bgFiles[rnd.nextInt(bgFiles.length)];
      final drawId = drawFile == null ? null : 'D${1 + rnd.nextInt(8)}';
      final row = drawFile == null ? null : rnd.nextInt(10);
      final col = drawFile == null ? null : rnd.nextInt(10);
      final network = networks[rnd.nextInt(networks.length)];
      final created = _randCreated();
      final updated = _randUpdatedAfter(created);
      final physical = _randCreated();
      final confirm = _randCreated();
      final normalC = '기본 비고 $id';
      final oaC = 'OA 비고 $id';
      String _mac() {
        String two() => rnd.nextInt(256).toRadixString(16).padLeft(2, '0');
        return List.generate(6, (_) => two()).join('-');
      }
      final mac = _mac();

      _items.add(Asset(
        id: id,
        code: code,
        name: name,
        category: cat2,
        serialNumber: sn,
        modelName: model,
        vendor: vendor,
        building: building,
        floor: floor,
        memberName: member,
        network: network,
        physicalCheckDate: physical,
        confirmationDate: confirm,
        normalComment: normalC,
        oaComment: oaC,
        macAddress: mac,
        locationDrawingId: drawId,
        locationRow: row,
        locationCol: col,
        locationDrawingFile: drawFile,
        createdAt: created,
        updatedAt: updated,
      ));
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
