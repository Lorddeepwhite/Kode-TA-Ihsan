import 'package:pdf/widgets.dart' as pw;
import 'package:ta_ihsan/domain/log_status_monitoring_link_error.dart';
import 'package:ta_ihsan/domain/terminal_link_error.dart';

class DashboardPdfWidget {
  static pw.Widget widget({
    required Map<dynamic, dynamic> ejbcaLog,
    required Map<dynamic, dynamic> terminalLog,
    required Map<dynamic, dynamic> snortLog,
    required Map<dynamic, dynamic> monitoringLog,
  }) {
    int insecureDesign = 0;

    int brokenAccessControl = 0;
    int injection = 0;
    int ssrf = 0;

    int totalSerangan = 0;

    ejbcaLog.forEach((key, value) {
      if (value["Tipe_Error"].contains("Broken Access Control")) {
        brokenAccessControl += 1;
      }
      if (value["Tipe_Error"].contains("Injection")) {
        injection += 1;
      }
      if (value["Tipe_Error"].contains("SSRF")) {
        ssrf += 1;
      }
      insecureDesign += 1;
      totalSerangan += 1;
    });

    int crypthoFailures = 0;
    int vulnerableOutdate = 0;

    terminalLog.forEach((key, value) {
      if (!value["IsiLog"].contains("TLS handshake")) {
        crypthoFailures += 1;
      }
      if (value["IsiLog"].toLowerCase().contains("wildfly") ||
          value["IsiLog"].toLowerCase().contains("ejbca")) {
        vulnerableOutdate += 1;
      }

      if (TerminalLinkError.getLink(value["IsiLog"]) != "-") {
        totalSerangan += 1;
      }

      String tipeError = "";
      if (value["IsiLog"].toLowerCase().contains("tls alert")) {
        tipeError = "cryptographic faillure";
      } else if (value["IsiLog"].toLowerCase().contains("tls handshake")) {
        tipeError = "cryptographic secure (non exploit)";
      } else if (value["IsiLog"].toLowerCase().contains("upgradable")) {
        tipeError = "vulnerable & outdated components";
      } else {
        tipeError = "cryptographic safe";
      }

      if (tipeError.contains("vulnerable & outdated components")) {
        vulnerableOutdate += 1;
      }
    });

    int securityMisconfiguration = 0;

    snortLog.forEach((key, value) {
      if (value["Exploit"]
          .toLowerCase()
          .contains("Brute Force".toLowerCase())) {
        securityMisconfiguration += 1;
      }
      if (value["Exploit"]
          .toLowerCase()
          .contains("Broken Access Control".toLowerCase())) {
        brokenAccessControl += 1;
      }
      if (value["Exploit"].toLowerCase().contains("Injection".toLowerCase())) {
        injection += 1;
      }
      if (value["Exploit"].toLowerCase().contains("SSRF".toLowerCase())) {
        ssrf += 1;
      }
      insecureDesign += 1;
      totalSerangan += 1;
    });

    String lastSecurityMonitoringFailures = "";
    monitoringLog.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        lastSecurityMonitoringFailures = value["Pesan_Kesalahan"] ?? "";

        if (LogStatusMonitoringLinkError.getLink(value["Pesan_Kesalahan"]) !=
            "-") {
          totalSerangan += 1;
        }
      }
    });

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Executive Summary",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(height: 15),
          titleWidget(),
          pw.SizedBox(height: 5),
          contentWidget(
            title: "Broken Access Control",
            value: brokenAccessControl.toString(),
          ),
          contentWidget(
            title: "Crytopgraphic Failures",
            value: crypthoFailures.toString(),
          ),
          contentWidget(
            title: "Injection",
            value: injection.toString(),
          ),
          contentWidget(
            title: "Insecure Design",
            value: insecureDesign > 0 ? "Insecure" : "Secure",
          ),
          contentWidget(
            title: "Security Misconfiguration",
            value: securityMisconfiguration.toString(),
          ),
          contentWidget(
            title: "Vulnerable & Outdate Components",
            value: vulnerableOutdate.toString(),
          ),
          contentWidget(
            title: "Server-Side Request Forgery",
            value: ssrf.toString(),
          ),
          contentWidget(
            title: "Identification & Authentication Failures",
            value: "N/A",
          ),
          contentWidget(
            title: "Security Monitoring Faillures",
            value: lastSecurityMonitoringFailures.contains(
                    "secure logging and monitoring failures".toLowerCase())
                ? "insecure"
                : "secure",
          ),
          contentWidget(
            title: "Total Serangan",
            value: totalSerangan.toString(),
          ),
        ],
      ),
    );
  }

  // static List<pw.Widget> contentData(List lists) {
  //   return List.generate(lists.length, (index) {
  //     try {
  //       Map<dynamic, dynamic> mapData = lists[index];
  //       return contentWidget(
  //         no: (index + 1).toString(),
  //         timeStamp: mapData["Timestamp"] ?? "",
  //         tanggal: mapData["Tanggal"] ?? "",
  //         logLevel: mapData["Log_Level"] ?? "",
  //         eventModule: mapData["Event_Module"] ?? "",
  //         serverService: mapData["Server_Service_Thread_Port"] ?? "",
  //         deskripsiEvent: mapData["Deskripsi_EventPaket_Input_Output"] ?? "",
  //         tipeError: mapData["Tipe_Error"] ?? "",
  //       );
  //     } catch (e) {
  //       return pw.Container();
  //     }
  //   });
  // }

  static pw.Widget contentWidget({
    required String title,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Row(
        children: [
          itemContentWidget(title, weight: 3),
          itemContentWidget(value),
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
          itemTitleWidget("Name", weight: 3),
          itemTitleWidget("Value"),
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
