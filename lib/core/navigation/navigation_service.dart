import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  
  factory NavigationService() => _instance;
  
  NavigationService._internal();
  
  // Store the router key to access context
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }
  
  static BuildContext? get context {
    return _navigatorKey?.currentContext;
  }
  
  static void navigateTo(String routeName, {Map<String, String>? params, Object? extra}) {
    context?.goNamed(routeName, pathParameters: params ?? {}, extra: extra);
  }
  
  static void navigateToWithQuery(
    String routeName, {
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    context?.goNamed(routeName, queryParameters: queryParams!, extra: extra);
  }
  
  static void goBack() {
    context?.pop();
  }
  
  static void replace(String routeName, {Map<String, String>? params, Object? extra}) {
    context?.goNamed(routeName, pathParameters: params ?? {}, extra: extra);
  }
  
  static void clearAndGo(String routeName, {Map<String, String>? params, Object? extra}) {
    while (context?.canPop() == true) {
      context?.pop();
    }
    context?.goNamed(routeName, pathParameters: params ?? {}, extra: extra);
  }
  
  // Additional helper methods
  static void pushNamed(String routeName, {Map<String, String>? params, Object? extra}) {
    context?.pushNamed(routeName, pathParameters: params ?? {}, extra: extra);
  }
  
  static void pushReplacementNamed(String routeName, {Map<String, String>? params, Object? extra}) {
    context?.pushReplacementNamed(routeName, pathParameters: params ?? {}, extra: extra);
  }
}