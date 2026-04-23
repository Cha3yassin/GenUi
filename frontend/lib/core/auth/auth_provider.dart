import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/app_config.dart';
import 'auth_models.dart';

/// Global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider for just checking if user is logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider for the current user's role.
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.role;
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _keyUserId = 'fb_user_id';
  static const _keyEmail = 'fb_email';
  static const _keyRole = 'fb_role';
  static const _keyToken = 'fb_token';

  /// Try to restore a previous session from SharedPreferences.
  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      final email = prefs.getString(_keyEmail);
      final role = prefs.getString(_keyRole);
      final token = prefs.getString(_keyToken);

      if (userId != null && email != null && role != null && token != null) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final freshToken = await firebaseUser.getIdToken(true);
          if (freshToken != null) {
            final user = AppUser(
              userId: userId,
              email: email,
              role: role,
              firebaseToken: freshToken,
            );
            await prefs.setString(_keyToken, freshToken);
            state = AuthState(
              user: user,
              status: AuthStatus.authenticated,
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
    }

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Full login flow: Google Sign-In → Firebase → POST /auth/login
  Future<void> login(String role) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ── WEB: Use Firebase Auth signInWithPopup ───────────────
        // This is the reliable approach for web — no google_sign_in needed.
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // ── MOBILE: Use google_sign_in package ───────────────────
        final gsi = GoogleSignIn.instance;
        await gsi.initialize();
        final account = await gsi.authenticate(scopeHint: ['email']);
        final idToken = account.authentication.idToken;
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase sign-in returned null user');
      }

      // Get Firebase ID token for backend verification
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // POST to backend /auth/login
      final uri = Uri.parse('${AppConfig.apiV1}/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': firebaseIdToken, 'role': role}),
      );

      if (response.statusCode != 200) {
        debugPrint('Backend login failed: ${response.statusCode} — ${response.body}');
        throw Exception('Backend login failed (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final appUser = AppUser(
        userId: data['user_id'] as String,
        email: data['email'] as String? ?? firebaseUser.email ?? '',
        role: data['role'] as String,
        firebaseToken: firebaseIdToken,
      );

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, appUser.userId);
      await prefs.setString(_keyEmail, appUser.email);
      await prefs.setString(_keyRole, appUser.role);
      await prefs.setString(_keyToken, appUser.firebaseToken);

      state = AuthState(
        user: appUser,
        status: AuthStatus.authenticated,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return;
      }
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Auth error: ${e.message ?? e.code}',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Sign out from Firebase and clear local state.
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyToken);
    } catch (_) {}

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Get a fresh Firebase token (auto-refreshes if expired).
  Future<String?> getFreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token != null && state.user != null) {
          state = state.copyWith(
            user: state.user!.copyWith(firebaseToken: token),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyToken, token);
        }
        return token;
      }
    } catch (_) {}
    return null;
  }
}
