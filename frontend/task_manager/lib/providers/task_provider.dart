import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'dart:async';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _statusFilter = '';
  Timer? _debounceTimer;

  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks();
      _applyFilters();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Create new timer - 300ms debounce
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _applyFilters();
    });
    
    // Update UI immediately for instant feedback
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      bool matchesSearch = true;
      bool matchesStatus = true;

      if (_searchQuery.isNotEmpty) {
        matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      if (_statusFilter.isNotEmpty) {
        matchesStatus = task.status == _statusFilter;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    try {
      await _apiService.createTask(task);
      await loadTasks();
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(int id, Task task) async {
    try {
      await _apiService.updateTask(id, task);
      await loadTasks();
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      await loadTasks();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> reorderTasks(List<Task> reorderedTasks) async {
    // Update local state immediately for smooth UX
    _filteredTasks = reorderedTasks;
    _tasks = reorderedTasks;
    notifyListeners();

    try {
      // Send to backend
      List<int> taskIds = reorderedTasks.map((t) => t.id!).toList();
      await _apiService.reorderTasks(taskIds);
    } catch (e) {
      print('Error reordering tasks: $e');
      // Reload to revert if failed
      await loadTasks();
    }
  }

  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isTaskBlocked(Task task) {
    if (task.blockedById == null) return false;
    
    Task? blockingTask = getTaskById(task.blockedById!);
    return blockingTask != null && blockingTask.status != 'Done';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
