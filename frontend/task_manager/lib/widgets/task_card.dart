import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import './highlighted_text.dart';


class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String searchQuery;
  final Task? blockingTask;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isBlocked,
    required this.onTap,
    this.onDelete,
    this.searchQuery = '',
    this.blockingTask,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (task.status) {
      case 'To-Do':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case 'To-Do':
        return Icons.radio_button_unchecked;
      case 'In Progress':
        return Icons.pending;
      case 'Done':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && task.status != 'Done';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isBlocked ? 1 : 3,
      color: isBlocked ? Colors.grey.shade200 : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: isBlocked ? Colors.grey : _getStatusColor(),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HighlightedText(
                          text: task.title,
                          highlight: searchQuery,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isBlocked ? Colors.grey.shade600 : Colors.black87,
                            decoration: task.status == 'Done' 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isBlocked ? Colors.grey.shade500 : Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: onDelete,
                    ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBlocked ? Colors.grey.shade400 : _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.status,
                      style: TextStyle(
                        color: isBlocked ? Colors.grey.shade700 : _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey.shade600,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (task.isRecurring != null) ...[
                    SizedBox(width: 8),
                    Icon(Icons.repeat, size: 14, color: Colors.purple),
                    SizedBox(width: 4),
                    Text(
                      task.isRecurring!,
                      style: TextStyle(fontSize: 12, color: Colors.purple),
                    ),
                  ],
                ],
              ),
              if (isBlocked && blockingTask != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 16, color: Colors.amber.shade900),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Blocked by: \${blockingTask!.title}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
