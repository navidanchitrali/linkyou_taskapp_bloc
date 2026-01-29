 import 'dart:async';

import 'package:flutter/material.dart';
  import '../../features/auth/presentation/bloc/session/session_bloc.dart';

 
 

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(SessionBloc sessionBloc) {
    print('🔄 GoRouterRefreshStream: Created');
    
    // Listen to session state changes
    _subscription = sessionBloc.stream.listen((state) {
      print('🔄 GoRouterRefreshStream: Session state changed to ${state.runtimeType}');
      
      // Trigger refresh on important state changes
      if (state is SessionAuthenticated || 
          state is SessionUnauthenticated ||
          state is SessionError) {
        print('   ↪️ Notifying router to refresh routes');
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}