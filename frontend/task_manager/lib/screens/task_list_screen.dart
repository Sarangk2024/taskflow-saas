import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import './task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "\${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<TaskProvider>(context, listen: false)
                    .deleteTask(task.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: \${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).loadTasks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              Provider.of<TaskProvider>(context, listen: false)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    Provider.of<TaskProvider>(context, listen: false)
                        .setSearchQuery(value);
                  },
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', ''),
                      SizedBox(width: 8),
                      _buildFilterChip('To-Do', 'To-Do'),
                      SizedBox(width: 8),
                      _buildFilterChip('In Progress', 'In Progress'),
                      SizedBox(width: 8),
                      _buildFilterChip('Done', 'Done'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                final tasks = taskProvider.tasks;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (taskProvider.searchQuery.isNotEmpty ||
                            taskProvider.statusFilter.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    
                    final List<Task> reorderedTasks = List.from(tasks);
                    final Task task = reorderedTasks.removeAt(oldIndex);
                    reorderedTasks.insert(newIndex, task);
                    
                    await taskProvider.reorderTasks(reorderedTasks);
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isBlocked = taskProvider.isTaskBlocked(task);
                    final blockingTask = task.blockedById != null
                        ? taskProvider.getTaskById(task.blockedById!)
                        : null;

                    return Padding(
                      key: ValueKey(task.id),
                      padding: EdgeInsets.only(bottom: 0),
                      child: TaskCard(
                        task: task,
                        isBlocked: isBlocked,
                        searchQuery: taskProvider.searchQuery,
                        blockingTask: blockingTask,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskFormScreen(task: task),
                            ),
                          );
                        },
                        onDelete: () => _showDeleteConfirmation(context, task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('New Task'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : '';
        });
        Provider.of<TaskProvider>(context, listen: false)
            .setStatusFilter(_selectedFilter);
      },
      selectedColor: Colors.indigo.shade100,
      checkmarkColor: Colors.indigo,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.indigo : Colors.grey.shade300,
        ),
      ),
    );
  }
}
