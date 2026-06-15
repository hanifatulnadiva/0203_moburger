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
    on<FetchReportData>((event, emit) async {
      print("DEBUG: Repository dipanggil");
      print("BLoC menerima event FetchReportData");
      emit(ReportLoading()); // Ini yang membuat loading berputar
      try {
        print("Mencoba ambil data dari: ${event.range.start} sampai ${event.range.end}");
        
        final data = await repository.fetchReport(event.range.start, event.range.end);
        
        print("Data berhasil didapat: $data"); // Cek apakah ini muncul di Debug Console
        emit(ReportLoaded(data));
      } catch (e) {
        print("ERROR DI BLOC: $e"); // JIKA NYANGKUT, PESAN INI AKAN MUNCUL DI CONSOLE
        emit(ReportError(e.toString()));
      }
    });
  }
}
