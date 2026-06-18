import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:moburger/data/models/report_model.dart';

/// Service untuk mengekspor [ReportModel] ke file Excel (.xlsx).
///
/// File berisi 2 sheet:
/// - "Ringkasan": total pendapatan, total transaksi, rata-rata order,
///   dan tren pendapatan harian.
/// - "Detail Produk": menu terlaris & topping terlaris.
class ReportExcelExporter {
  static final _currencyFormat = NumberFormat.decimalPattern('id_ID');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _fileDateFormat = DateFormat('ddMMyyyy');

  /// Membuat file Excel dari [data] untuk rentang [start] - [end],
  /// menyimpannya ke direktori sementara, lalu membuka dialog share/save.
  static Future<void> exportAndShare({
    required ReportModel data,
    required DateTime start,
    required DateTime end,
  }) async {
    final excel = Excel.createExcel();

    _buildSummarySheet(excel, data, start, end);
    _buildDetailSheet(excel, data);

    // Sheet default "Sheet1" dari createExcel() dihapus karena tidak dipakai.
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Gagal mengenkode file Excel.');
    }

    final dir = await getTemporaryDirectory();
    final fileName =
        'Laporan_Penjualan_${_fileDateFormat.format(start)}-${_fileDateFormat.format(end)}.xlsx';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Laporan Penjualan MoBurger',
    );
  }

  static void _buildSummarySheet(
    Excel excel,
    ReportModel data,
    DateTime start,
    DateTime end,
  ) {
    final sheet = excel['Ringkasan'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('#53190E'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final labelStyle = CellStyle(bold: true);

    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('B1'),
    );
    sheet.updateCell(
      CellIndex.indexByString('A1'),
      TextCellValue('LAPORAN PENJUALAN MOBURGER'),
      cellStyle: headerStyle,
    );

    sheet.updateCell(
      CellIndex.indexByString('A2'),
      TextCellValue('Periode'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B2'),
      TextCellValue(
        '${_dateFormat.format(start)} - ${_dateFormat.format(end)}',
      ),
    );

    sheet.updateCell(
      CellIndex.indexByString('A4'),
      TextCellValue('Total Pendapatan'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B4'),
      TextCellValue('Rp ${_currencyFormat.format(data.totalRevenue)}'),
    );

    sheet.updateCell(
      CellIndex.indexByString('A5'),
      TextCellValue('Total Transaksi'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B5'),
      IntCellValue(data.totalTransactions),
    );

    sheet.updateCell(
      CellIndex.indexByString('A6'),
      TextCellValue('Rata-rata Nilai Transaksi'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B6'),
      TextCellValue('Rp ${_currencyFormat.format(data.averageOrderValue)}'),
    );

    // Tabel tren pendapatan harian
    int row = 8;
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      TextCellValue('Tanggal'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      TextCellValue('Pendapatan (Rp)'),
      cellStyle: labelStyle,
    );
    row++;

    for (final item in data.revenueTrend) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
        TextCellValue(_dateFormat.format(item.date)),
      );
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
        DoubleCellValue(item.amount),
      );
      row++;
    }

    sheet.setColumnWidth(0, 22);
    sheet.setColumnWidth(1, 22);
  }

  static void _buildDetailSheet(Excel excel, ReportModel data) {
    final sheet = excel['Detail Produk'];
    final labelStyle = CellStyle(bold: true);

    sheet.updateCell(
      CellIndex.indexByString('A1'),
      TextCellValue('Menu Terlaris'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('A2'),
      TextCellValue('Nama Menu'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B2'),
      TextCellValue('Jumlah Terjual'),
      cellStyle: labelStyle,
    );

    int row = 3;
    for (final menu in data.topMenus) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row - 1),
        TextCellValue(menu.name),
      );
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row - 1),
        IntCellValue(menu.count),
      );
      row++;
    }

    // Beri jarak 2 baris sebelum tabel topping
    int toppingHeaderRow = row + 1;
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: toppingHeaderRow),
      TextCellValue('Topping Terlaris'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: toppingHeaderRow + 1,
      ),
      TextCellValue('Nama Topping'),
      cellStyle: labelStyle,
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(
        columnIndex: 1,
        rowIndex: toppingHeaderRow + 1,
      ),
      TextCellValue('Jumlah Terjual'),
      cellStyle: labelStyle,
    );

    int toppingRow = toppingHeaderRow + 2;
    for (final topping in data.topToppings) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: toppingRow),
        TextCellValue(topping.name),
      );
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: toppingRow),
        IntCellValue(topping.count),
      );
      toppingRow++;
    }

    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 18);
  }
}