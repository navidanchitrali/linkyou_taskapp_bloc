 import 'package:go_router/go_router.dart';
 import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
 import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../features/tasks/presentation/screens/add_edit_task_screen.dart';


 
 
// final goRouter = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/login',
//       name: 'login',
//       builder: (context, state) => const LoginScreen(),
//     ),
//     GoRoute(
//       path: '/',
//       name: 'home',
//       builder: (context, state) => const TaskListScreen(),
//       routes: [
//         GoRoute(
//           path: 'add-task',
//           name: 'addTask',
//           builder: (context, state) => const AddEditTaskScreen(),
//         ),
//         GoRoute(
//           path: 'edit-task',
//           name: 'editTask', // Remove :id from path
//           builder: (context, state) {
//             // Get task from extra parameter
//             final task = state.extra as Task?;
//             if (task != null) {
//               return AddEditTaskScreen(task: task);
//             }
//             return const AddEditTaskScreen(); // Fallback
//           },
//         ),
//       ],
//     ),
//   ],
//   initialLocation: '/login',
//   // ... rest of router config
// );





