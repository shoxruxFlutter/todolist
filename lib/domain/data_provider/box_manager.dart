import 'package:hive/hive.dart';
import 'package:todolist/domain/entity/group.dart';
import 'package:todolist/domain/entity/task.dart';

class BoxManager {
  static final BoxManager instance = BoxManager._();
  static Map<String, int> boxCounter = <String, int>{};

  BoxManager._();

  Future<Box<T>> _openBox<T>(
      String name, int typeId, TypeAdapter<T> adapter) async {
    if (Hive.isBoxOpen(name)) {
      var count = boxCounter[name] ?? 1;
      boxCounter[name] = count + 1;
      return Hive.box(name);
    }
    boxCounter[name] = 1;
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }
    return Hive.openBox<T>(name);
  }

  Future<Box<Group>> openGroupBox() async {
    return _openBox('groups_box', 1, GroupAdapter());
  }

  Future<Box<Task>> openTasksBox(int groupKey) async {
    return _openBox(makeTaskBoxName(groupKey), 2, TaskAdapter());
  }

  Future<void> closeBox<T>(Box<T> box) async {
    if (!box.isOpen) {
      boxCounter.remove(box.name);
      return;
    }
    var count = boxCounter[box.name] ?? 1;
    boxCounter[box.name] = count - 1;
    if (count > 0) return;
    boxCounter.remove(box.name);
    await box.compact();
    await box.close();
  }

  String makeTaskBoxName(int groupKey) => 'tasks_box_$groupKey';
}
