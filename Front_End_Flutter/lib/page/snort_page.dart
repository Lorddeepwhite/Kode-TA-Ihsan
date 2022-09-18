import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class SnortPage extends StatelessWidget {
  const SnortPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference reference =
        FirebaseDatabase.instance.ref("snort_log");

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
    } else if (exploitNonExploit.toLowerCase().contains("cryptographic failures")) {
      link = "https://owasp.org/Top10/id/A02_2021-Cryptographic_Failures/";
    } else if (exploitNonExploit.toLowerCase().contains("injection")) {
      link = "https://owasp.org/Top10/id/A03_2021-Injection/";
    } else if (exploitNonExploit.toLowerCase().contains("insecure design")) {
      link = "https://owasp.org/Top10/id/A04_2021-Insecure_Design/";
    } else if (exploitNonExploit.toLowerCase().contains("security misconfiguration")) {
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
    bool isEvenNumber = int.parse(no) % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      color: isEvenNumber
          ? Colors.lightBlue.withOpacity(0.1)
          : Colors.blue.withOpacity(0.3),
      child: Row(
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
