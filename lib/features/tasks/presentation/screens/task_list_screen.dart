import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkyou_tasks_app/core/theme/app_theme.dart';
import 'package:linkyou_tasks_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_state.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TaskListBloc _taskListBloc;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _taskListBloc = context.read<TaskListBloc>();
    _taskListBloc.add(LoadTasks());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
      final state = _taskListBloc.state;
      if (state is TaskListLoaded && state.hasMore) {
        _taskListBloc.add(LoadMoreTasks());
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkBackground : AppColors.background;
  }

  Color _getSurfaceColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkSurface : AppColors.surface;
  }

  Color _getTextPrimaryColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  }

  Color _getBorderColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkBorder : AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });
          }
        },
        child: Scaffold(
          backgroundColor: _getBackgroundColor(context),
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _getSurfaceColor(context),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'TaskFlow',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: _getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: _getTextPrimaryColor(context),
          ),
          onPressed: _toggleTheme,
        ),
        BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionAuthenticated) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        state.user.firstName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_outlined, size: 20, color: _getTextPrimaryColor(context)),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: _getTextPrimaryColor(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocConsumer<TaskListBloc, TaskListState>(
      listener: (context, state) {
        if (state is TaskListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TaskListLoading && _taskListBloc.allTasks.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (state is TaskListInitial) {
          return _buildLoadingShimmer();
        }

        if (state is TaskListError) {
          return _buildErrorState(state);
        }

        if (state is TaskListLoaded) {
          if (state.tasks.isEmpty) {
            return _buildEmptyState();
          }
          return _buildTaskList(state.tasks, state.hasMore);
        }

        if (state is TaskListLoadingMore) {
          return _buildTaskList(state.tasks, state.hasMore);
        }

        if (state is TaskListRefreshing) {
          return _buildTaskList(state.tasks ?? [], state.hasMore);
        }

        return _buildLoadingShimmer();
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool hasMore) {
    return RefreshIndicator(
      onRefresh: () async {
        _taskListBloc.add(RefreshTasks());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      backgroundColor: _getSurfaceColor(context),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tasks.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= tasks.length) {
            return _buildLoadMoreIndicator();
          }
          
          final task = tasks[index];
          return _buildTaskTile(task);
        },
      ),
    );
  }
Widget _buildTaskTile(Task task) {
  final timeAgo = _getTimeAgo(task.createdAt);
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: _getSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _getBorderColor(context),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(_isDarkMode ? 0.2 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle task tap
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion indicator with gradient
              GestureDetector(
                onTap: () {
                  _taskListBloc.add(TaskCompletedToggled(task: task));
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: task.completed 
                      ? LinearGradient(
                          colors: [AppColors.accent, Color(0xFF34D399)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: task.completed 
                        ? Colors.transparent 
                        : _getBorderColor(context),
                      width: 2,
                    ),
                    color: task.completed ? null : Colors.transparent,
                  ),
                  child: Center(
                    child: task.completed
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getTextDisabledColor(context),
                          ),
                        ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task text
                    Text(
                      task.todo,
                      style: task.completed
                        ? AppTextStyles.bodyLarge.copyWith(
                            color: _getTextSecondaryColor(context),
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          )
                        : AppTextStyles.bodyLarge.copyWith(
                            color: _getTextPrimaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: _getTextSecondaryColor(context),
                            ),
                            SizedBox(width: 6),
                            Text(
                              timeAgo,
                              style: AppTextStyles.caption.copyWith(
                                color: _getTextSecondaryColor(context),
                              ),
                            ),
                            
                            
                            SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.completed
                                  ? AppColors.accent.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.completed ? 'Completed' : 'Pending',
                                style: AppTextStyles.caption.copyWith(
                                  color: task.completed ? AppColors.accent : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                     
                        _buildTaskMenu(task),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTaskMenu(Task task) {
  return PopupMenuButton<String>(
    icon: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getBorderColor(context).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: _getTextSecondaryColor(context),
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    onSelected: (value) {
      if (value == 'edit') {
        // Handle edit - navigate to edit screen or show edit dialog
        _showEditTaskDialog(task);
      } else if (value == 'delete') {
        _showDeleteConfirmationDialog(task);
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 20, color: _getTextPrimaryColor(context)),
            SizedBox(width: 12),
            Text(
              'Edit',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
            SizedBox(width: 12),
            Text(
              'Delete',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void _showEditTaskDialog(Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: _getSurfaceColor(context),
      title: Text(
        'Edit Task',
        style: AppTextStyles.titleMedium.copyWith(
          color: _getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: task.todo),
            decoration: InputDecoration(
              filled: true,
              fillColor: _getBackgroundColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _getBorderColor(context)),
              ),
              hintText: 'Enter task description',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: _getTextSecondaryColor(context),
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getTextPrimaryColor(context),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement task update logic
                    // _taskListBloc.add(UpdateTaskInList(task: updatedTask));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: AppTextStyles.buttonMedium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void _showDeleteConfirmationDialog(Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: _getSurfaceColor(context),
      title: Text(
        'Delete Task',
        style: AppTextStyles.titleMedium.copyWith(
          color: _getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this task?',
        style: AppTextStyles.bodyMedium.copyWith(
          color: _getTextSecondaryColor(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: _getTextSecondaryColor(context),
          ),
          child: Text('Cancel', style: AppTextStyles.bodyMedium),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _taskListBloc.add(DeleteTaskFromList(taskId: task.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: Text('Delete', style: AppTextStyles.buttonMedium),
        ),
      ],
    ),
  );
}
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
  }

  Color _getTextDisabledColor(BuildContext context) {
    return _isDarkMode ? AppColors.darkTextDisabled : AppColors.textDisabled;
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Loading more tasks',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isDarkMode ? AppColors.darkShimmerBase : AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _isDarkMode ? AppColors.darkShimmerBase : AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isDarkMode ? AppColors.darkShimmerBase : AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        _taskListBloc.add(RefreshTasks());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      backgroundColor: _getSurfaceColor(context),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_outlined,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'All Clear!',
                style: AppTextStyles.titleLarge.copyWith(
                  color: _getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No tasks yet. Add your first task\nand start being productive!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed('addTask');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Create Task', style: AppTextStyles.buttonMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(TaskListError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: AppColors.danger,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Unable to Load Tasks',
              style: AppTextStyles.titleMedium.copyWith(
                color: _getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _taskListBloc.add(LoadTasks());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Try Again', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        context.pushNamed('addTask');
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: _getSurfaceColor(context),
        title: Text(
          'Logout',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: _getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: _getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _getTextSecondaryColor(context),
            ),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Logging out...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getTextPrimaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              
              context.read<SessionBloc>().add(LogoutRequested());
              
              await Future.delayed(const Duration(milliseconds: 300));
              
              if (context.mounted) {
                Navigator.of(context).pop();
                context.go('/login');
                while (context.canPop()) {
                  context.pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}