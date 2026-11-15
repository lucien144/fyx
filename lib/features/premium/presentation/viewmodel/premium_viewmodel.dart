import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/premium/domain/entities/christmas_unlock.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_state.dart';
import 'package:fyx/model/MainRepository.dart';

/// Owns the premium gate. Loads the cached status on [init], refreshes in the
/// background when the cache is not fresh, and re-evaluates freshness on
/// every entry point. Only a successful "not premium" refresh or the end of
/// the grace period turns premium off (ADR 0002).
class PremiumViewModel extends ChangeNotifier {
  final PremiumRepository _repository;
  final String? Function() _getNickname;
  final DateTime Function() _clock;
  final void Function(Object error, StackTrace stack) _logError;

  PremiumViewModel(
    this._repository, {
    String? Function()? getNickname,
    DateTime Function()? clock,
    void Function(Object error, StackTrace stack)? logError,
  })  : _getNickname = getNickname ?? _credentialsNickname,
        _clock = clock ?? DateTime.now,
        _logError = logError ?? _captureError;

  static String? _credentialsNickname() => MainRepository().credentials?.nickname.toLowerCase();

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  PremiumState _state = const PremiumState();

  PremiumState get state => _state;

  /// Loads the cache and kicks off a background refresh when it is not
  /// fresh. Never blocks on the network — callers must not await the refresh.
  Future<void> init() async {
    final nickname = _getNickname();
    if (nickname == null) {
      clear();
      return;
    }
    _apply(await _repository.getCached(nickname));
    if (_state.freshness != PremiumFreshness.fresh) {
      refresh(); // deliberately not awaited
    }
  }

  /// Re-evaluates freshness against the current clock and refreshes unless
  /// the cache is still fresh. Called on app resume.
  Future<void> refreshIfStale() async {
    if (_state.isRefreshing) return;
    _apply(_state.status); // also re-evaluates the Christmas unlock
    if (_state.freshness == PremiumFreshness.fresh) return;
    await refresh();
  }

  /// Fetches from Supabase. On failure the previous status stays in effect
  /// and [PremiumState.lastRefreshFailed] is set.
  Future<void> refresh() async {
    final nickname = _getNickname();
    if (nickname == null || _state.isRefreshing) return;
    _state = _state.copyWith(isRefreshing: true);
    notifyListeners();
    try {
      _apply(await _repository.refresh(nickname), refreshFailed: false);
    } catch (e, stack) {
      _logError(e, stack);
      _apply(_state.status, refreshFailed: true);
    }
  }

  /// Resets to the empty state (logout).
  void clear() {
    _state = const PremiumState();
    notifyListeners();
  }

  void _apply(PremiumStatus? status, {bool? refreshFailed}) {
    final now = _clock();
    final isPremium = status?.isPremiumAt(now) ?? false;
    _state = PremiumState(
      status: status,
      freshness: status?.freshnessAt(now) ?? PremiumFreshness.none,
      isPremium: isPremium,
      isUnlocked: isPremium || ChristmasUnlock.isActive(now),
      isRefreshing: false,
      lastRefreshFailed: refreshFailed ?? _state.lastRefreshFailed,
    );
    notifyListeners();
  }
}
