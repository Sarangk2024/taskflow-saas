import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<Task>> getTasks({String? search, String? status}) async {
    var uri = Uri.parse('$baseUrl/tasks');
    
    Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> getTask(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<Task> updateTask(int id, Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['detail'] ?? 'Failed to delete task');
    }
  }

  Future<void> reorderTasks(List<int> taskIds) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/reorder'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskIds),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reorder tasks');
    }
  }
}
