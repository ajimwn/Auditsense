export 'export_helper_stub.dart'
    if (dart.library.html) 'export_helper_web.dart';

String createCsvContent(List<List<dynamic>> rows) {
  String escapeCsvValue(Object? value) {
    final text = value?.toString() ?? '';
    final escaped = text.replaceAll('"', '""');
    final needsQuotes =
        text.contains(',') ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  return rows.map((row) => row.map(escapeCsvValue).join(',')).join('\r\n');
}
