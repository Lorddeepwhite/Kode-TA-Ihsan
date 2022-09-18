import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class RekomendasiMitigasiForensikPage extends StatelessWidget {
  const RekomendasiMitigasiForensikPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        titleWidget(),
        const SizedBox(height: 25),
        ...contentData(),
      ],
    );
  }

  List<Widget> contentData() {
    return [
      contentWidget(
          no: "1",
          tipe: "broken access control",
          link: "https://owasp.org/Top10/id/A01_2021-Broken_Access_Control/"),
      contentWidget(
          no: "2",
          tipe: "cryptographic failures",
          link: "https://owasp.org/Top10/id/A02_2021-Cryptographic_Failures/"),
      contentWidget(
          no: "3",
          tipe: "injection",
          link: "https://owasp.org/Top10/id/A03_2021-Injection/"),
      contentWidget(
          no: "4",
          tipe: "insecure design",
          link: "https://owasp.org/Top10/id/A04_2021-Insecure_Design/"),
      contentWidget(
          no: "5",
          tipe: "security misconfiguration",
          link:
              "https://owasp.org/Top10/id/A05_2021-Security_Misconfiguration/"),
      contentWidget(
          no: "6",
          tipe: "vulnerable & outdated components",
          link:
              "https://owasp.org/Top10/id/A06_2021-Vulnerable_and_Outdated_Components/"),
      contentWidget(
          no: "7",
          tipe: "server-side request forgery (SSRF)",
          link:
              "https://owasp.org/Top10/id/A10_2021-Server-Side_Request_Forgery_(SSRF)/"),
      contentWidget(
          no: "1",
          tipe: "identification & authentication failures",
          link:
              "https://owasp.org/Top10/id/A07_2021-Identification_and_Authentication_Failures/"),
    ];
  }

  Widget contentWidget({
    required String no,
    required String tipe,
    required String link,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          itemContentWidget(no, weight: 1),
          itemContentWidget(tipe, weight: 10, textAlign: TextAlign.start),
          itemContentWidget(
            link,
            weight: 10,
            textAlign: TextAlign.start,
            onTap: () {
              html.window.open(link, 'new tab');
            },
          ),
        ],
      ),
    );
  }

  Widget itemContentWidget(String title,
      {int weight = 3, TextAlign? textAlign, VoidCallback? onTap}) {
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
          textAlign: textAlign ?? TextAlign.center,
        ),
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          itemTitleWidget("No", weight: 1),
          itemTitleWidget("Tipe Eksploit", weight: 10),
          itemTitleWidget("Link Rekomendasi Mitigasi", weight: 10),
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
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
