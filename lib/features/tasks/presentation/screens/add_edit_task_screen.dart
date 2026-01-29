import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkyou_tasks_app/core/di/dependency_injection.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/session/session_bloc.dart';
import '../bloc/task_list/task_list_bloc.dart';

 

class AddEditTaskScreen extends StatefulWidget {
  final String? taskId;
  final Task? task;

  const AddEditTaskScreen({Key? key, this.taskId, this.task}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}
class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isCompleted = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null || widget.taskId != null;
    
    if (widget.task != null) {
      // Task passed via extra parameter
      _titleController.text = widget.task!.todo;
      _isCompleted = widget.task!.completed;
    } else if (widget.taskId != null) {
      // Load task by ID
      _loadTask(widget.taskId!);
    }
  }

  Future<void> _loadTask(String taskId) async {
    setState(() => _isLoading = true);
    
    try {
      // Use dependency injection or context to get repository
      final taskRepository = getIt<TaskRepository>();
      final task = await taskRepository.getTaskById(taskId);
      
      setState(() {
        _titleController.text = task.todo;
        _isCompleted = task.completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load task: $e')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

 
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Task' : 'Add Task', style: AppTextStyles.titleLarge),
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(),
            const SizedBox(height: 24),
            _buildCompletionToggle(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Task Title', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'What needs to be done?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          style: AppTextStyles.bodyLarge,
          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a task title' : null,
        ),
      ],
    );
  }

  Widget _buildCompletionToggle() {
    return Row(
      children: [
        Switch(value: _isCompleted, onChanged: (value) => setState(() => _isCompleted = value), activeColor: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
              Text(_isCompleted ? 'Completed' : 'Pending', style: AppTextStyles.bodyMedium.copyWith(color: _isCompleted ? AppColors.accent : AppColors.warning)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppColors.border),
            ),
            child: Text('Cancel', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_isEditing ? 'Update' : 'Save', style: AppTextStyles.buttonLarge),
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    
    final sessionState = context.read<SessionBloc>().state;
    if (sessionState is! SessionAuthenticated) return;

    if (_isEditing) {
      final taskId = widget.task?.id ?? widget.taskId!;
      final updatedTask = Task(
        id: taskId,
        todo: _titleController.text.trim(),
        completed: _isCompleted,
        userId: int.parse(sessionState.user.id),
      );
      
      context.read<TaskListBloc>().add(UpdateTaskInList(task: updatedTask));
    } else {
      context.read<TaskListBloc>().add(AddTaskToList(
        todo: _titleController.text.trim(),
        userId: int.parse(sessionState.user.id),
      ));
    }
    
    context.pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}