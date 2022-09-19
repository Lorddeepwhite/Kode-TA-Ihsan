import 'package:pdf/widgets.dart' as pw;

class MonitoringFailureLogPdfWidget {
  static pw.Widget widget(List listData) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Log Status Monitoring",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(height: 15),
          titleWidget(),
          pw.SizedBox(height: 5),
          ...contentData(listData),
        ],
      ),
    );
  }

  static List<pw.Widget> contentData(List lists) {
    return List.generate(lists.length, (index) {
      try {
        Map<dynamic, dynamic> mapData = lists[index];
        return contentWidget(
          no: (index + 1).toString(),
          filePath: mapData["Filepath"] ?? "",
          pesanKesalahan: mapData["Pesan_Kesalahan"] ?? "",
          tanggal: mapData["Tanggal"] ?? "",
        );
      } catch (e) {
        return pw.Container();
      }
    });
  }

  static pw.Widget contentWidget({
    required String no,
    required String filePath,
    required String pesanKesalahan,
    required String tanggal,
  }) {
    String link = "-";
    if (pesanKesalahan
        .toLowerCase()
        .contains("secure logging and monitoring failures".toLowerCase())) {
      link =
          "https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/";
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Row(
        children: [
          itemContentWidget(no, weight: 1),
          itemContentWidget(filePath),
          itemContentWidget(pesanKesalahan),
          itemContentWidget(tanggal),
          itemContentWidget(link),
        ],
      ),
    );
  }

  static pw.Widget itemContentWidget(String title, {int weight = 3}) {
    return pw.Expanded(
      flex: weight,
      child: pw.Text(
        title,
        style: const pw.TextStyle(
          fontSize: 6,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget titleWidget() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Row(
        children: [
          itemTitleWidget("No", weight: 1),
          itemTitleWidget("Filepath"),
          itemTitleWidget("Pesan status Log Monitoring"),
          itemTitleWidget("Tanggal"),
          itemTitleWidget("Rekomendasi Mitigasi Forensik")
        ],
      ),
    );
  }

  static pw.Widget itemTitleWidget(String title, {int weight = 3}) {
    return pw.Expanded(
      flex: weight,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
