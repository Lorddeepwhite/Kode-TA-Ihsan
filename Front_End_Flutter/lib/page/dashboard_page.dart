import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference reference = FirebaseDatabase.instance.ref();

    return StreamBuilder(
        stream: reference.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            try {
              DatabaseEvent? event = snapshot.data as DatabaseEvent?;
              DataSnapshot? dataValues = event?.snapshot;
              Map<dynamic, dynamic> values =
                  dataValues?.value as Map<dynamic, dynamic>;
              Map<dynamic, dynamic> ejbcaLog = values["EJBCA_log"] ?? {};
              Map<dynamic, dynamic> terminalLog = values["terminal_log"] ?? {};
              Map<dynamic, dynamic> snortLog = values["snort_log"] ?? {};
              Map<dynamic, dynamic> monitoringLog =
                  values["monitoring_failure_log"] ?? {};

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
                totalSerangan += 1;
              });

              int securityMisconfiguration = 0;

              snortLog.forEach((key, value) {
                if (value["Pesan_Alert"].contains("Brute Force")) {
                  securityMisconfiguration += 1;
                }
                insecureDesign += 1;
                totalSerangan += 1;
              });

              String lastSecurityMonitoringFailures = "";
              monitoringLog.forEach((key, value) {
                if (value is Map<String, dynamic>) {
                  lastSecurityMonitoringFailures =
                      value["Pesan_Kesalahan"] ?? "";
                }
              });

              return SizedBox(
                child: Column(
                  children: [
                    Row(
                      children: [
                        itemContentGrey(
                          title: "Broken Access Control",
                          value: brokenAccessControl.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Crytopgraphic Failures",
                          value: crypthoFailures.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Injection",
                          value: injection.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Insecure Design",
                          value: insecureDesign > 0 ? "Insecure" : "Secure",
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        itemContentGrey(
                          title: "Security Misconfiguration",
                          value: securityMisconfiguration.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Vulnerable & Outdate Components",
                          value: vulnerableOutdate.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Server-Side Request Forgery",
                          value: ssrf.toString(),
                          color: Colors.blue,
                        ),
                        itemContentGrey(
                          title: "Identification & Authentication Failures",
                          value: "0",
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        itemContentGrey(
                          title: "Security Monitoring Faillures",
                          value: lastSecurityMonitoringFailures.contains("secure logging and monitoring failures".toLowerCase()) ? "insecure" : "secure",
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        itemContentGrey(
                          title: "Total Serangan",
                          value: totalSerangan.toString(),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     itemContentGrey(
                    //         title: "Total Data yang Dipindai", value: "0"),
                    //   ],
                    // ),
                  ],
                ),
              );
            } catch (e) {
              return const Center(child: Text("No Data"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget itemContentGrey(
      {required String title, required String value, Color? color}) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: color != null
              ? color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
