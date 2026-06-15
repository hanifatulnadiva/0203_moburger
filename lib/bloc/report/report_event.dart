part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}
class FetchReportData extends ReportEvent {
  final DateTimeRange range;
  FetchReportData(this.range);
}