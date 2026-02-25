import 'package:equatable/equatable.dart';
import 'package:vertecx/data/models/request/request_model.dart';

class RequestsState extends Equatable {
  final List<ServiceRequestModel> all;
  final List<ServiceRequestModel> filtered;
  final List<ServiceRequestModel> visible;
  final String query;
  final bool loading;
  final bool loadingMore;
  final int pageSize;
  final int visibleCount;
  final String? error;

  const RequestsState({
    this.all = const [],
    this.filtered = const [],
    this.visible = const [],
    this.query = '',
    this.loading = false,
    this.loadingMore = false,
    this.pageSize = 6,
    this.visibleCount = 0,
    this.error,
  });

  bool get hasMore => visible.length < filtered.length;

  RequestsState copyWith({
    List<ServiceRequestModel>? all,
    List<ServiceRequestModel>? filtered,
    List<ServiceRequestModel>? visible,
    String? query,
    bool? loading,
    bool? loadingMore,
    int? pageSize,
    int? visibleCount,
    String? error,
  }) {
    return RequestsState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      visible: visible ?? this.visible,
      query: query ?? this.query,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      pageSize: pageSize ?? this.pageSize,
      visibleCount: visibleCount ?? this.visibleCount,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [all, filtered, visible, query, loading, loadingMore, pageSize, visibleCount, error];
}
