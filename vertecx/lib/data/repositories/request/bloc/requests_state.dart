import 'package:equatable/equatable.dart';
import 'package:vertecx/data/models/request/request_model.dart';

enum RequestsSortOrder { newestFirst, oldestFirst }

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
  final RequestsSortOrder sortOrder;

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
    this.sortOrder = RequestsSortOrder.newestFirst,
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
    RequestsSortOrder? sortOrder,
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
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        all,
        filtered,
        visible,
        query,
        loading,
        loadingMore,
        pageSize,
        visibleCount,
        error,
        sortOrder,
      ];
}
