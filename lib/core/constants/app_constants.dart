class AppConstants {
  static const String appName = 'TaskFlow';
  static const String baseUrl = 'https://dummyjson.com';
  static const int itemsPerPage = 10;
  static const int apiTimeout = 30000;
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'app_theme';
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String todos = '/todos';
  static const String addTodo = '/todos/add';
  static String todoById(int id) => '/todos/$id';
}

class AppStrings {
  static const String appTitle = 'TaskFlow';
  static const String emailHint = 'Username';
  static const String passwordHint = 'Password';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete';
  static const String markComplete = 'Mark Complete';
  static const String markIncomplete = 'Mark Incomplete';
  static const String taskTitle = 'Title';
  static const String taskDescription = 'Description';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String noTasks = 'No tasks yet';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String completed = 'Completed';
  static const String pending = 'Pending';
}