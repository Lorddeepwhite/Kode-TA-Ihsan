import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class MonitoringFailureLogPage extends StatelessWidget {
  const MonitoringFailureLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference reference =
        FirebaseDatabase.instance.ref("monitoring_failure_log");

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
              filePath: mapData["Filepath"] ?? "",
              pesanKesalahan: mapData["Pesan_Kesalahan"] ?? "",
              tanggal: mapData["Tanggal"] ?? "",
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
    required String filePath,
    required String pesanKesalahan,
    required String tanggal,
  }) {
    String link = "-";
    if (pesanKesalahan.toLowerCase().contains("secure logging and monitoring failures".toLowerCase())) {
      link = "https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/";
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
          itemContentWidget(filePath),
          itemContentWidget(pesanKesalahan),
          itemContentWidget(tanggal),
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
          itemTitleWidget("Filepath"),
          itemTitleWidget("Pesan status Log Monitoring"),
          itemTitleWidget("Tanggal"),
          itemTitleWidget("Rekomendasi Mitigasi Forensik")
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
