import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ta_ihsan/helper/print_pdf_helper.dart';
import 'package:ta_ihsan/page/dashboard_page.dart';
import 'package:ta_ihsan/page/ejbca_page.dart';
import 'package:ta_ihsan/page/monitoring_failure_log_page.dart';
import 'package:ta_ihsan/page/output_terminal_page.dart';
import 'package:ta_ihsan/page/rekomendasi_mitigasi_forensik_page.dart';
import 'package:ta_ihsan/page/snort_page.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 0;
  List<Widget> pageList = const [
    DashboardPage(),
    MonitoringFailureLogPage(),
    EjbcaPage(),
    SnortPage(),
    OutputTerminalPage(),
    // RekomendasiMitigasiForensikPage(),
  ];
  String responseStatus = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(
                "Digital Forensic Readiness EJBCA",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Material(
                elevation: 10,
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buttonAction(),
                    Material(
                      elevation: 10,
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                buttonSelect(
                                  isSelected: selectedPage == 0,
                                  onPressed: () {
                                    setState(() {
                                      selectedPage = 0;
                                    });
                                  },
                                  title: "Executive Summary",
                                ),
                                const SizedBox(width: 30),
                                buttonSelect(
                                  isSelected: selectedPage == 1,
                                  onPressed: () {
                                    setState(() {
                                      selectedPage = 1;
                                    });
                                  },
                                  title: "Log Status Monitoring",
                                ),
                                const SizedBox(width: 30),
                                buttonSelect(
                                  isSelected: selectedPage == 2,
                                  onPressed: () {
                                    setState(() {
                                      selectedPage = 2;
                                    });
                                  },
                                  title: "Log EJBCA",
                                ),
                                const SizedBox(width: 30),
                                buttonSelect(
                                  isSelected: selectedPage == 3,
                                  onPressed: () {
                                    setState(() {
                                      selectedPage = 3;
                                    });
                                  },
                                  title: "Log Snort",
                                ),
                                const SizedBox(width: 30),
                                buttonSelect(
                                  isSelected: selectedPage == 4,
                                  onPressed: () {
                                    setState(() {
                                      selectedPage = 4;
                                    });
                                  },
                                  title: "Log Server via Terminal",
                                ),

                                // const SizedBox(width: 30),
                                // buttonSelect(
                                //   isSelected: selectedPage == 4,
                                //   onPressed: () {
                                //     setState(() {
                                //       selectedPage = 4;
                                //     });
                                //   },
                                //   title: "Rekomendasi Mitigasi Forensik",
                                // ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            contentWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonAction() {
    final DatabaseReference reference = FirebaseDatabase.instance.ref("config");

    return StreamBuilder(
        stream: reference.onValue,
        builder: (context, snapshot) {
          try {
            DatabaseEvent? event = snapshot.data as DatabaseEvent?;
            DataSnapshot? dataValues = event?.snapshot;
            Map<dynamic, dynamic> values =
                dataValues?.value as Map<dynamic, dynamic>;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Material(
                    elevation: 10,
                    color: Colors.grey,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () async {
                        String? postBody = values["post_body"];
                        String? url = values["url"];

                        if (url != null) {
                          if (postBody != null && postBody.isNotEmpty) {
                            final response = await http.post(
                              Uri.parse(url),
                              body: postBody,
                            );
                            setState(() {
                              responseStatus = response.statusCode.toString();
                            });
                          } else {
                            final response = await http.get(Uri.parse(url));
                            setState(() {
                              responseStatus = response.statusCode.toString();
                            });
                          }
                        }
                      },
                      splashFactory: InkRipple.splashFactory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          values["button_text"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder<Object>(
                    stream: FirebaseDatabase.instance.ref().onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          !snapshot.hasError &&
                          snapshot.data != null) {
                        try {
                          DatabaseEvent? event =
                              snapshot.data as DatabaseEvent?;
                          DataSnapshot? dataValues = event?.snapshot;
                          Map<dynamic, dynamic> values =
                              dataValues?.value as Map<dynamic, dynamic>;
                          Map<dynamic, dynamic> ejbcaLog =
                              values["EJBCA_log"] ?? {};
                          Map<dynamic, dynamic> terminalLog =
                              values["terminal_log"] ?? {};
                          Map<dynamic, dynamic> snortLog =
                              values["snort_log"] ?? {};
                          Map<dynamic, dynamic> monitoringLog =
                              values["monitoring_failure_log"] ?? {};

                          List ejbcaLoglists = [];
                          ejbcaLog.forEach((key, values) {
                            ejbcaLoglists.add(values);
                          });

                          List terminalLoglists = [];
                          terminalLog.forEach((key, values) {
                            terminalLoglists.add(values);
                          });

                          List snortLoglists = [];
                          snortLog.forEach((key, values) {
                            snortLoglists.add(values);
                          });

                          List monitoringLists = [];
                          monitoringLog.forEach((key, values) {
                            monitoringLists.add(values);
                          });

                          return buttonCustom(
                            title: "Cetak Laporan",
                            onPressed: () {
                              PrintPdfHelper.createPdf(
                                ejbcaLoglists: ejbcaLoglists,
                                terminalLoglists: terminalLoglists,
                                snortLoglists: snortLoglists,
                                monitoringList: monitoringLists,
                                ejbcaLog: ejbcaLog,
                                terminalLog: terminalLog,
                                snortLog: snortLog,
                                monitoringLog: monitoringLog,
                              );
                            },
                          );
                        } catch (e) {
                          return const SizedBox();
                        }
                      }

                      return const SizedBox();
                    }),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    responseStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          responseStatus == "200" ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            );
          } catch (e) {
            return Container();
          }
        });
  }

  Widget buttonCustom(
      {required String title, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Material(
        elevation: 10,
        color: Colors.grey,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () async {
            onPressed();
          },
          splashFactory: InkRipple.splashFactory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget contentWidget() {
    return pageList[selectedPage];
  }

  Widget buttonSelect({
    required bool isSelected,
    required VoidCallback onPressed,
    required String title,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      color: isSelected ? Colors.grey : Colors.white,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        onTap: () {
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
