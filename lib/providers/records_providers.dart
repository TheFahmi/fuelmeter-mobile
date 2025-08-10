import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/records_repository.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  return RecordsRepository(Supabase.instance.client);
});

class RecordsPaginationState {
  const RecordsPaginationState({
    this.items = const [],
    this.page = 0,
    this.isLoading = false,
    this.hasMore = true,
  });
  final List<Map<String, dynamic>> items;
  final int page;
  final bool isLoading;
  final bool hasMore;

  RecordsPaginationState copyWith({
    List<Map<String, dynamic>>? items,
    int? page,
    bool? isLoading,
    bool? hasMore,
  }) {
    return RecordsPaginationState(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class RecordsPaginationNotifier extends StateNotifier<RecordsPaginationState> {
  RecordsPaginationNotifier(this._repo) : super(const RecordsPaginationState());
  final RecordsRepository _repo;
  static const _pageSize = 20;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final items = await _repo.fetchPage(page: 1, pageSize: _pageSize);
    state = RecordsPaginationState(
        items: items,
        page: 1,
        isLoading: false,
        hasMore: items.length == _pageSize);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    final items = await _repo.fetchPage(page: nextPage, pageSize: _pageSize);
    state = RecordsPaginationState(
      items: [...state.items, ...items],
      page: nextPage,
      isLoading: false,
      hasMore: items.length == _pageSize,
    );
  }
}

final recordsPaginationProvider =
    StateNotifierProvider<RecordsPaginationNotifier, RecordsPaginationState>(
        (ref) {
  final repo = ref.read(recordsRepositoryProvider);
  final notifier = RecordsPaginationNotifier(repo);
  // auto load first page lazily
  Future.microtask(() => notifier.refresh());
  return notifier;
});

final recordDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final repo = ref.read(recordsRepositoryProvider);
  return await repo.fetchById(id);
});
