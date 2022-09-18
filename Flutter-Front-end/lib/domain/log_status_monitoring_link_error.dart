class LogStatusMonitoringLinkError {
  static String getLink(String pesanKesalahan) {
    String link = "-";
    if (pesanKesalahan
        .toLowerCase()
        .contains("secure logging and monitoring failures".toLowerCase())) {
      link =
          "https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/";
    }

    return link;
  }
}
