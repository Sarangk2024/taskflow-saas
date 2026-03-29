import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/draft_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _draftService = DraftService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedStatus;
  int? _blockedById;
  String? _recurring;
  bool _isSubmitting = false;
  bool _isDraftLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _selectedDate = widget.task?.dueDate ?? DateTime.now().add(Duration(days: 1));
    _selectedStatus = widget.task?.status ?? 'To-Do';
    _blockedById = widget.task?.blockedById;
    _recurring = widget.task?.isRecurring;
    
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    
    // Load draft if creating new task
    if (widget.task == null) {
      _loadDraft();
    }
    
    // Auto-save draft as user types
    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
  }

  Future<void> _loadDraft() async {
    final draft = await _draftService.loadDraft();
    if (draft != null && !_isDraftLoaded) {
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _descriptionController.text = draft['description'] ?? '';
        if (draft['due_date'] != null) {
          _selectedDate = DateTime.parse(draft['due_date']);
        }
        _selectedStatus = draft['status'] ?? 'To-Do';
        _blockedById = draft['blocked_by_id'];
        _recurring = draft['is_recurring'];
        _isDraftLoaded = true;
      });
    }
  }

  void _saveDraft() {
    if (widget.task == null) {
      _draftService.saveDraft({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'due_date': _selectedDate.toIso8601String(),
        'status': _selectedStatus,
        'blocked_by_id': _blockedById,
        'is_recurring': _recurring,
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _saveDraft();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate,
      status: _selectedStatus,
      blockedById: _blockedById,
      isRecurring: _recurring,
    );

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (widget.task == null) {
        await taskProvider.createTask(task);
        await _draftService.clearDraft();
      } else {
        await taskProvider.updateTask(widget.task!.id!, task);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task == null ? 'Task created!' : 'Task updated!'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final availableTasks = taskProvider.tasks
        .where((t) => t.id != widget.task?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Due Date'),
              subtitle: Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
              leading: Icon(Icons.calendar_today),
              trailing: Icon(Icons.edit),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _selectDate,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: ['To-Do', 'In Progress', 'Done']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _saveDraft();
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _blockedById,
              decoration: InputDecoration(
                labelText: 'Blocked By (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.block),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('None')),
                ...availableTasks.map((task) => DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _blockedById = value;
                  _saveDraft();
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _recurring,
              decoration: InputDecoration(
                labelText: 'Recurring (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                setState(() {
                  _recurring = value;
                  _saveDraft();
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Saving... (2s delay simulation)'),
                      ],
                    )
                  : Text(
                      widget.task == null ? 'Create Task' : 'Update Task',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
