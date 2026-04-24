/// Auth models for the Fbureaucracy app.

enum AuthStatus { unknown, authenticated, unauthenticated }

enum UserRole { individual, enterprise }

class AppUser {
  const AppUser({
    required this.userId,
    required this.email,
    required this.role,
    required this.firebaseToken,
  });

  final String userId;
  final String email;
  final String role; // "individual" or "enterprise"
  final String firebaseToken;

  AppUser copyWith({
    String? userId,
    String? email,
    String? role,
    String? firebaseToken,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      firebaseToken: firebaseToken ?? this.firebaseToken,
    );
  }
}

class AuthState {
  const AuthState({
    this.user,
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.error,
  });

  final AppUser? user;
  final AuthStatus status;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AppUser? user,
    AuthStatus? status,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
