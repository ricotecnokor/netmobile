class Constants {
  static const bool useLocal = false;

  static const String _localBaseUrl = "http://localhost:5000/api";
  static const String _oldBaseUrl = "http://192.168.200.67:8004/api";

  static String get baseUrl => useLocal ? _localBaseUrl : _oldBaseUrl;

  static String get produtosEndpoint => "$baseUrl/produtos";
  static String get raizEndpoint => "$baseUrl/componentes/raiz";
  static String get componenteEndpoint => "$baseUrl/componentes";
  static String get pdfEndpoint => "$baseUrl/Pdf";
}
