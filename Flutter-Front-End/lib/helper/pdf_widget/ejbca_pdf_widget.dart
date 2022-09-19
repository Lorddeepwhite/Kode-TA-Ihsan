import 'package:pdf/widgets.dart' as pw;

class EJBCAPdfWidget {
  static pw.Widget widget(List ejbcaLoglists) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Log EJCBA",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(height: 15),
          titleWidget(),
          pw.SizedBox(height: 5),
          ...contentData(ejbcaLoglists),
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
          timeStamp: mapData["Timestamp"] ?? "",
          tanggal: mapData["Tanggal"] ?? "",
          logLevel: mapData["Log_Level"] ?? "",
          eventModule: mapData["Event_Module"] ?? "",
          serverService: mapData["Server_Service_Thread_Port"] ?? "",
          deskripsiEvent: mapData["Deskripsi_EventPaket_Input_Output"] ?? "",
          tipeError: mapData["Tipe_Error"] ?? "",
        );
      } catch (e) {
        return pw.Container();
      }
    });
  }

  static pw.Widget contentWidget({
    required String no,
    required String timeStamp,
    required String tanggal,
    required String logLevel,
    required String eventModule,
    required String serverService,
    required String deskripsiEvent,
    required String tipeError,
  }) {
    String link = "";
    if (tipeError.toLowerCase().contains("broken access control")) {
      link = "https://owasp.org/Top10/id/A01_2021-Broken_Access_Control/";
    } else if (tipeError.toLowerCase().contains("SSRF".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A10_2021-Server-Side_Request_Forgery_(SSRF)/";
    } else if (tipeError.toLowerCase().contains("cryptographic failures")) {
      link = "https://owasp.org/Top10/id/A02_2021-Cryptographic_Failures/";
    } else if (tipeError.toLowerCase().contains("injection")) {
      link = "https://owasp.org/Top10/id/A03_2021-Injection/";
    } else if (tipeError.toLowerCase().contains("insecure design")) {
      link = "https://owasp.org/Top10/id/A04_2021-Insecure_Design/";
    } else if (tipeError.toLowerCase().contains("security misconfiguration")) {
      link = "https://owasp.org/Top10/id/A05_2021-Security_Misconfiguration/";
    } else if (tipeError
        .toLowerCase()
        .contains("vulnerable & outdated components")) {
      link =
          "https://owasp.org/Top10/id/A06_2021-Vulnerable_and_Outdated_Components/";
    } else if (tipeError
        .toLowerCase()
        .contains("server-side request forgery (SSRF)".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A10_2021-Server-Side_Request_Forgery_(SSRF)/";
    } else if (tipeError
        .toLowerCase()
        .contains("identification & authentication failures".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A07_2021-Identification_and_Authentication_Failures/";
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Row(
        children: [
          itemContentWidget(no, weight: 1),
          itemContentWidget(timeStamp),
          itemContentWidget(tanggal),
          itemContentWidget(logLevel),
          itemContentWidget(eventModule),
          itemContentWidget(serverService, weight: 5),
          itemContentWidget(deskripsiEvent, weight: 5),
          itemContentWidget(tipeError),
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
          itemTitleWidget("Timestamp"),
          itemTitleWidget("Tanggal"),
          itemTitleWidget("Log Level"),
          itemTitleWidget("Event Module"),
          itemTitleWidget("Server Service Thread Pool Port", weight: 5),
          itemTitleWidget("Deskripsi Event Paket I/O", weight: 5),
          itemTitleWidget("Tipe Eksploitasi"),
          itemTitleWidget("Rekomendasi Mitigasi Forensik"),
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
