part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportModel summary;

  final ReportModel trend;

  final DateTimeRange activeRange;

  final bool isDefaultView;

  const ReportLoaded({
    required this.summary,
    required this.trend,
    required this.activeRange,
    required this.isDefaultView,
  });

  @override
  List<Object?> get props => [summary, trend, activeRange, isDefaultView];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}