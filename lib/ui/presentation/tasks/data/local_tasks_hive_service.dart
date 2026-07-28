import 'package:el_race/core/logging/app_logger.dart';
import 'package:hive/hive.dart';
import 'task_model.dart';

class LocalTasksHiveService {
  static const String _boxName = 'local_tasks_box';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    try {
      _box = await Hive.openBox<dynamic>(_boxName);
    } catch (e) {
      AppLogger.warning('LocalTasksHiveService: failed to open box', error: e);
    }
  }

  static Future<Box<dynamic>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  static Future<void> saveLocalTasks(List<TaskModel> tasks) async {
    try {
      final box = await _getBox();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      await box.put('local_tasks', jsonList);
    } catch (e) {
      AppLogger.warning('LocalTasksHiveService: failed to save tasks',
          error: e);
    }
  }

  static Future<List<TaskModel>> loadLocalTasks() async {
    try {
      final box = await _getBox();
      final dynamic data = box.get('local_tasks');

      if (data == null) return [];

      if (data is List) {
        return data
            .map((item) =>
                TaskModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      return [];
    } catch (e) {
      AppLogger.warning('LocalTasksHiveService: failed to load tasks',
          error: e);
      return [];
    }
  }

  static Future<void> clearLocalTasks() async {
    try {
      final box = await _getBox();
      await box.delete('local_tasks');
    } catch (e) {
      AppLogger.warning('LocalTasksHiveService: failed to clear tasks',
          error: e);
    }
  }
}
