import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ta_ihsan/helper/pdf_widget/ejbca_pdf_widget.dart';
import 'package:ta_ihsan/helper/pdf_widget/output_terminal_pdf_widget.dart';
import 'package:ta_ihsan/helper/pdf_widget/snort_pdf_widget.dart';

class PrintPdfHelper {
  static Future<void> createPdf({
    required List ejbcaLoglists,
    required List terminalLoglists,
    required List snortLoglists,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return EJBCAPdfWidget.widget(ejbcaLoglists);
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return SnortPdfWidget.widget(snortLoglists);
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return OutputTerminalPdfWidget.widget(terminalLoglists);
        },
      ),
    );

    Uint8List data = await pdf.save();

    MimeType type = MimeType.PDF;
    await FileSaver.instance.saveFile(
        "Laporan Digital Forensic Readiness EJBCA", data, "pdf",
        mimeType: type);
  }
}
