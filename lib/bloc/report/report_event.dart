part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Dipanggil saat halaman pertama kali dibuka.
/// Mengambil ringkasan HARI INI + tren penjualan 7 hari terakhir.
class FetchTodayReport extends ReportEvent {}

/// Dipanggil saat user memilih rentang tanggal custom (termasuk per bulan).
/// Ringkasan & tren grafik akan mengikuti rentang yang dipilih.
class FetchReportData extends ReportEvent {
  final DateTimeRange range;
  const FetchReportData(this.range);

  @override
  List<Object?> get props => [range];
}