class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final int? blockedById;
  final String? isRecurring;
  final int customOrder;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.isRecurring,
    this.customOrder = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      blockedById: json['blocked_by_id'],
      isRecurring: json['is_recurring'],
      customOrder: json['custom_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status,
      'blocked_by_id': blockedById,
      'is_recurring': isRecurring,
      'custom_order': customOrder,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    int? blockedById,
    String? isRecurring,
    int? customOrder,
    bool clearBlockedBy = false,
    bool clearRecurring = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: clearBlockedBy ? null : (blockedById ?? this.blockedById),
      isRecurring: clearRecurring ? null : (isRecurring ?? this.isRecurring),
      customOrder: customOrder ?? this.customOrder,
    );
  }
}
