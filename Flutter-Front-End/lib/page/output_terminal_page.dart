import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class OutputTerminalPage extends StatelessWidget {
  const OutputTerminalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference reference =
        FirebaseDatabase.instance.ref("terminal_log");

    return StreamBuilder(
        stream: reference.onValue,
        builder: (context, snapshot) {
          return Column(
            children: [
              titleWidget(),
              ...contentData(snapshot),
            ],
          );
        });
  }

  List<Widget> contentData(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
      try {
        DatabaseEvent? event = snapshot.data as DatabaseEvent?;
        DataSnapshot? dataValues = event?.snapshot;
        Map<dynamic, dynamic> values =
            dataValues?.value as Map<dynamic, dynamic>;
        List lists = [];
        lists.clear();
        values.forEach((key, values) {
          lists.add(values);
        });
        return List.generate(lists.length, (index) {
          try {
            Map<dynamic, dynamic> mapData = lists[index];
            return contentWidget(
              no: (index + 1).toString(),
              timeStamp: mapData["Tanggal"] ?? "",
              isiLog: mapData["IsiLog"] ?? "",
            );
          } catch (e) {
            return Container();
          }
        });
      } catch (e) {
        return [const Center(child: Text("No Data"))];
      }
    } else if (snapshot.hasError) {
      return [const Center(child: Text("Something Went Wrong"))];
    } else {
      return [const Center(child: CircularProgressIndicator())];
    }
  }

  Widget contentWidget({
    required String no,
    required String timeStamp,
    required String isiLog,
  }) {
    String tipeError = "";
    if (isiLog.toLowerCase().contains("tls alert")) {
      tipeError = "cryptographic faillure";
    } else if (isiLog.toLowerCase().contains("tls handshake")) {
      tipeError = "cryptographic secure (non exploit)";
    } else if (isiLog.toLowerCase().contains("upgradable")) {
      tipeError = "vulnerable & outdated components";
    } else {
      tipeError = "cryptographic safe";
    }

    String link = "-";
    if (tipeError.toLowerCase().contains("broken access control")) {
      link = "https://owasp.org/Top10/id/A01_2021-Broken_Access_Control/";
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
    } else if (tipeError.toLowerCase().contains("cryptographic faillure")) {
      link = "https://owasp.org/Top10/A02_2021-Cryptographic_Failures/";
    }

    bool isEvenNumber = int.parse(no) % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      color: isEvenNumber
          ? Colors.lightBlue.withOpacity(0.1)
          : Colors.blue.withOpacity(0.3),
      child: Row(
        children: [
          itemContentWidget(no, weight: 1),
          itemContentWidget(timeStamp, weight: 4),
          itemContentWidget(isiLog, weight: 10),
          itemContentWidget(tipeError),
          itemContentWidget(
            link,
            onTap: () {
              html.window.open(link, 'new tab');
            },
          ),
        ],
      ),
    );
  }

  Widget itemContentWidget(String title,
      {int weight = 3, VoidCallback? onTap}) {
    return Expanded(
      flex: weight,
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      color: Colors.blue,
      child: Row(
        children: [
          itemTitleWidget("No", weight: 1),
          itemTitleWidget("Timestamp", weight: 4),
          itemTitleWidget("Isi Log", weight: 10),
          itemTitleWidget("Tipe Eksploit"),
          itemTitleWidget("Rekomendasi Mitigasi Forensik"),
        ],
      ),
    );
  }

  Widget itemTitleWidget(String title, {int weight = 3}) {
    return Expanded(
      flex: weight,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
