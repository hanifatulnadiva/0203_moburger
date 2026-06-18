import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moburger/data/models/report_model.dart';
import 'package:moburger/data/repositories/report_repository.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc(this.repository) : super(ReportInitial()) {
    on<FetchTodayReport>(_onFetchToday);
    on<FetchReportData>(_onFetchCustomRange);
  }

  Future<void> _onFetchToday(
    FetchTodayReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = startOfToday
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // Rentang untuk grafik tren: 7 hari terakhir (termasuk hari ini).
      final trendStart = startOfToday.subtract(const Duration(days: 6));

      final results = await Future.wait([
        repository.fetchReport(startOfToday, endOfToday),
        repository.fetchReport(trendStart, endOfToday),
      ]);

      emit(ReportLoaded(
        summary: results[0],
        trend: results[1],
        activeRange: DateTimeRange(start: startOfToday, end: endOfToday),
        isDefaultView: true,
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onFetchCustomRange(
    FetchReportData event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      // Pastikan end date mencakup keseluruhan hari yang dipilih.
      final start = DateTime(
        event.range.start.year,
        event.range.start.month,
        event.range.start.day,
      );
      final end = DateTime(
        event.range.end.year,
        event.range.end.month,
        event.range.end.day,
      ).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      final data = await repository.fetchReport(start, end);

      emit(ReportLoaded(
        summary: data,
        // Untuk custom range, tren grafik = data yang sama (mengikuti filter).
        trend: data,
        activeRange: DateTimeRange(start: start, end: end),
        isDefaultView: false,
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}