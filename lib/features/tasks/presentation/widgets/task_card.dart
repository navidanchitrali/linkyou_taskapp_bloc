import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/task.dart';
 import '../bloc/task_list/task_list_bloc.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [_buildCompletionIndicator(context), _buildTaskContent(), _buildActionButtons(context)],
      ),
    );
  }

 Widget _buildCompletionIndicator(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Dispatch the toggle event
      context.read<TaskListBloc>().add(TaskCompletedToggled(task: task));
    },
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: task.completed ? AppColors.accent.withOpacity(0.1) : AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Icon(
        task.completed ? Icons.check_circle : Icons.circle_outlined,
        color: task.completed ? AppColors.accent : AppColors.textDisabled,
        size: 24,
      ),
    ),
  );
}
  Widget _buildTaskContent() {
    final isLocalTask = task.id.startsWith('local_');
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Constants.mediumPadding, horizontal: Constants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLocalTask)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('LOCAL', style: AppTextStyles.caption.copyWith(color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                Expanded(
                  child: Text(
                    task.todo,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: AppColors.textDisabled,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.completed ? AppColors.accent.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.completed ? 'Completed' : 'Pending',
                    style: AppTextStyles.caption.copyWith(
                      color: task.completed ? AppColors.accent : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('ID: ${task.id.length > 10 ? '${task.id.substring(0, 10)}...' : task.id}', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: AppColors.danger), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.danger))])),
      ],
    );
  }

void _handleMenuAction(BuildContext context, String value) {
  if (value == 'edit') {
    // Pass the entire task object to edit screen using pushNamed
    context.pushNamed('editTask', extra: task);
  } else if (value == 'delete') {
    _showDeleteConfirmation(context);
  }
}

void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Task'),
      content: const Text('Are you sure you want to delete this task?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<TaskListBloc>().add(DeleteTaskFromList(taskId: task.id));
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
}