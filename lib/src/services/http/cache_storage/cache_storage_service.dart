import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/repositories/cache_storage_repo.dart';

class CacheStorageImpl implements CacheStorageRepo {
  late Box<dynamic> hiveBox;

  @override
  Future<void> init() async {
    await openBox();
  }

  // static Box<dynamic> get customersBox => Hive.box<dynamic>("diocache");
  // static Map<Box<dynamic>, dynamic Function(dynamic json)> get allBoxes => {
  //       customersBox: (json) => CachedResponse.fromJson(json),
  //     };

  Future<void> openBox([String boxName = 'diocache']) async {
    hiveBox = await Hive.openBox<dynamic>(boxName);
    //await hiveBox.clear();
    //hiveBox.put(AppConfig.databaseVersionKey, AppConfig.databaseVersion);
  }

  @override
  Future<void> remove(String key) async {
    await hiveBox.delete(key);
  }

  @override
  dynamic get(String key) {
    return hiveBox.get(key);
  }

  @override
  dynamic getAll() {
    return hiveBox.values.toList();
  }

  @override
  bool has(String key) {
    return hiveBox.containsKey(key);
  }

  @override
  Future<void> set(String? key, dynamic data) async {
    await hiveBox.put(key, data);
  }

  @override
  Future<void> clear() async {
    await hiveBox.clear();
  }

  @override
  Future<void> close() async {
    await hiveBox.close();
  }
}
