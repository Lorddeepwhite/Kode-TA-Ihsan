import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
  List lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final DatabaseReference reference =
                              FirebaseDatabase.instance.ref("data_log");
                          await reference.remove();
                        },
                        child: const Text("Delete All Data"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "List Data",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(child: streamDataWidget()),
        ],
      ),
    );
  }

  Widget streamDataWidget() {
    final DatabaseReference reference =
        FirebaseDatabase.instance.ref("data_log");

    return StreamBuilder(
      stream: reference.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
          try {
            DatabaseEvent? event = snapshot.data as DatabaseEvent?;
            DataSnapshot? dataValues = event?.snapshot;
            Map<dynamic, dynamic> values =
                dataValues?.value as Map<dynamic, dynamic>;

            lists.clear();
            values.forEach((key, values) {
              lists.add(values);
            });
            return Scrollbar(
              isAlwaysShown: true,
              thickness: 10,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  try {
                    Map<dynamic, dynamic> mapData = lists[index];
                    return itemWidget(mapData);
                  } catch (e) {
                    return Container();
                  }
                },
              ),
            );
          } catch (e) {
            return const Center(child: Text("No Data"));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something Went Wrong"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget itemWidget(var mapData) {
    String logLevel = mapData["Log_Level"] ?? "<empty>";
    String desc = mapData["Deskripsi_EventPaket_Input_Output"] ?? "<empty>";
    String eventModule = mapData["Event_Module"] ?? "<empty>";
    String port = mapData["Server_Service_Thread_Port"] ?? "<empty>";
    String tanggal = mapData["Tanggal"] ?? "<empty>";
    String timeStamp = mapData["Timestamp"] ?? "<empty>";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Material(
        color: logLevel == "INFO" ? Colors.blue : Colors.green,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          splashFactory: InkRipple.splashFactory,
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              "LogLevel: $logLevel\nDesc: $desc"
              "Event Module: $eventModule\nPort: $port\nTanggal: $tanggal\nTimeStamp: $timeStamp",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
