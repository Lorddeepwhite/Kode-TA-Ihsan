import 'package:pdf/widgets.dart' as pw;

class SnortPdfWidget {
  static pw.Widget widget(List snortLoglists) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Log Snort",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(height: 15),
          titleWidget(),
          pw.SizedBox(height: 5),
          ...contentData(snortLoglists),
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
          sid: mapData["SID"] ?? "",
          prioritas: mapData["Prioritas"] ?? "",
          port: mapData["Port"] ?? "",
          pesanAlert: mapData["Pesan_Alert"] ?? "",
          paketIO: mapData["Paket_Input_Output"] ?? "",
          exploitNonExploit: mapData["Exploit"] ?? "",
          ip: mapData["IP"] ?? "",
          ipAddress: mapData["IP_Address"] ?? "",
        );
      } catch (e) {
        return pw.Container();
      }
    });
  }

  static pw.Widget contentWidget({
    required String no,
    required String timeStamp,
    required String sid,
    required String prioritas,
    required String port,
    required String pesanAlert,
    required String paketIO,
    required String exploitNonExploit,
    required String ip,
    required String ipAddress,
  }) {
    String link = "-";
    if (exploitNonExploit.toLowerCase().contains("broken access control")) {
      link = "https://owasp.org/Top10/id/A01_2021-Broken_Access_Control/";
    } else if (exploitNonExploit.toLowerCase().contains("SSRF".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A10_2021-Server-Side_Request_Forgery_(SSRF)/";
    } else if (exploitNonExploit
        .toLowerCase()
        .contains("cryptographic failures")) {
      link = "https://owasp.org/Top10/id/A02_2021-Cryptographic_Failures/";
    } else if (exploitNonExploit.toLowerCase().contains("injection")) {
      link = "https://owasp.org/Top10/id/A03_2021-Injection/";
    } else if (exploitNonExploit.toLowerCase().contains("insecure design")) {
      link = "https://owasp.org/Top10/id/A04_2021-Insecure_Design/";
    } else if (exploitNonExploit
        .toLowerCase()
        .contains("security misconfiguration")) {
      link = "https://owasp.org/Top10/id/A05_2021-Security_Misconfiguration/";
    } else if (exploitNonExploit
        .toLowerCase()
        .contains("vulnerable & outdated components")) {
      link =
          "https://owasp.org/Top10/id/A06_2021-Vulnerable_and_Outdated_Components/";
    } else if (exploitNonExploit
        .toLowerCase()
        .contains("server-side request forgery (SSRF)".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A10_2021-Server-Side_Request_Forgery_(SSRF)/";
    } else if (exploitNonExploit
        .toLowerCase()
        .contains("identification & authentication failures".toLowerCase())) {
      link =
          "https://owasp.org/Top10/id/A07_2021-Identification_and_Authentication_Failures/";
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: pw.Row(
        children: [
          itemContentWidget(no, weight: 1),
          itemContentWidget(timeStamp),
          // itemContentWidget(sid),
          // itemContentWidget(prioritas),
          itemContentWidget(port),
          itemContentWidget(pesanAlert, weight: 4),
          itemContentWidget(paketIO, weight: 6),
          itemContentWidget(exploitNonExploit, weight: 4),
          itemContentWidget(ip, weight: 2),
          itemContentWidget(ipAddress),
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
          // itemTitleWidget("SID"),
          // itemTitleWidget("Prioritas"),
          itemTitleWidget("Port"),
          itemTitleWidget("Pesan_Alert", weight: 4),
          itemTitleWidget("Paket I/O", weight: 6),
          itemTitleWidget("Tipe Eksploitasi", weight: 4),
          itemTitleWidget("IP", weight: 2),
          itemTitleWidget("IP_Address"),
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
