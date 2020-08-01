part of 'grid_data_bloc.dart';

enum GridDataStateCode {
  Loading,
  Normal,
  Empty,
  Error,
}

@immutable
class GridDataState extends Equatable {
  final String searchString;
  final int page;
  final bool hasReachedMax;
  final String message;
  final List<GridData> gridData;
  final bool uploadingMore;
  final GridDataStateCode stateCode;
  final String sequenceTitle;

  GridDataState({
    this.searchString,
    this.page,
    this.hasReachedMax,
    this.gridData,
    this.uploadingMore,
    this.stateCode,
    this.message,
    this.sequenceTitle,
  });

  @override
  List<Object> get props => [
        this.page,
        this.searchString,
        this.hasReachedMax,
        this.uploadingMore,
        this.stateCode,
        this.message,
        this.gridData?.length,
      ];

  GridDataState copyWith({
    String searchString,
    int page,
    bool hasReachedMax,
    List<GridData> gridData,
    bool uploadingMore,
    GridDataStateCode stateCode,
    String sequenceTitle,
    String message,
  }) {
    return GridDataState(
      searchString: searchString ?? this.searchString,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      gridData: gridData ?? this.gridData,
      uploadingMore: uploadingMore ?? this.uploadingMore,
      stateCode: stateCode ?? this.stateCode,
      message: message ?? this.message,
      sequenceTitle: sequenceTitle ?? this.sequenceTitle,
    );
  }
}
