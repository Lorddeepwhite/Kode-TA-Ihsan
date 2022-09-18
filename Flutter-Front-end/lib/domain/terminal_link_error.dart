class TerminalLinkError {
  static String getLink(String isiLog) {
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

    return link;
  }
}
