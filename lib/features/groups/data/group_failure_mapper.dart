import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';

/// [fallback] é a falha da ação ("Não foi possível carregar...") quando a
/// causa não tem texto próprio.
GroupFailure groupFailureFrom(SupabaseFailure failure, GroupFailure fallback) {
  debugPrint('[GroupFailure] ${failure.message} (${failure.code})');
  return switch (failure.kind) {
    SupabaseFailureKind.network => const GroupNetworkFailure(),
    SupabaseFailureKind.unauthorized => const GroupSessionExpiredFailure(),
    SupabaseFailureKind.forbidden => const GroupForbiddenFailure(),
    _ => fallback,
  };
}
