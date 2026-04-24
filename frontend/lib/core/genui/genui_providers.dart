import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'profile_config.dart';

final selectedProfileProvider =
    StateProvider<ProfileType>((ref) => ProfileType.individual);

final effectiveProfileProvider = Provider<ProfileType>((ref) {
  final role = ref.watch(userRoleProvider);
  if (role == 'individual' || role == 'enterprise') {
    return profileFromRole(role);
  }
  return ref.watch(selectedProfileProvider);
});

final profileLockedProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'individual' || role == 'enterprise';
});
