part of 'report_bloc.dart';

sealed class ReportState extends Equatable {
  const ReportState();
  
  @override
  List<Object> get props => [];
}

final class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}
class ReportLoaded extends ReportState {
  final ReportModel data;
  ReportLoaded(this.data);
}
final class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}
