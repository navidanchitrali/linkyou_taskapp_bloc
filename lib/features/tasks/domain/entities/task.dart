class Task {
  final String id;
  final String todo;
  final bool completed;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;   
  final String? serverId;
  final bool isLocal;
  final bool isSynced;
  final bool isDeleted;

  Task({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.serverId,
    this.isLocal = true,
    this.isSynced = false,
    this.isDeleted = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();  

  Task copyWith({
    String? id,
    String? todo,
    bool? completed,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? isLocal,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),  
      serverId: serverId ?? this.serverId,
      isLocal: isLocal ?? this.isLocal,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

 

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'serverId': serverId,
      'isLocal': isLocal,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      todo: json['todo'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      serverId: json['serverId'],
      isLocal: json['isLocal'] ?? true,
      isSynced: json['isSynced'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

enum TaskSyncStatus {
  pending,    // Needs to be synced
  syncing,    // Currently syncing
  synced,     // Successfully synced
  failed,     // Sync failed
}