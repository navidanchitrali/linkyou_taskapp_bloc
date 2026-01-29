import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkyou_tasks_app/core/di/dependency_injection.dart';
import 'package:linkyou_tasks_app/core/navigation/navigation_service.dart';
import 'package:linkyou_tasks_app/core/theme/app_theme.dart';
import 'package:linkyou_tasks_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:linkyou_tasks_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:linkyou_tasks_app/features/auth/presentation/screens/login_screen.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/screens/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionBloc(
            authRepository: getIt<AuthRepository>(),
          )..add(CheckSession()),
        ),
        BlocProvider(
          create: (context) => TaskListBloc(
            taskRepository: getIt<TaskRepository>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          NavigationService.setNavigatorKey(navigatorKey);
          
          return MaterialApp.router(
            title: 'TaskFlow',
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(context),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(BuildContext context) {
    return GoRouter(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const TaskListScreen(),
          routes: [
            GoRoute(
              path: 'add-task',
              name: 'addTask',
              builder: (context, state) => const AddEditTaskScreen(),
            ),
            GoRoute(
              path: 'edit-task',
              name: 'editTask',
              builder: (context, state) {
                final task = state.extra as Task?;
                if (task != null) {
                  return AddEditTaskScreen(task: task);
                }
                return const AddEditTaskScreen();
              },
            ),
          ],
        ),
      ],
      initialLocation: '/login',
      redirect: (context, state) {
        final sessionState = context.read<SessionBloc>().state;
        final isAuthenticated = sessionState is SessionAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found', style: Theme.of(context).textTheme.headlineLarge!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}