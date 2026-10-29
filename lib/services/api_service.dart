
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final http.Client _client;

  ApiService() : _client = http.Client();

  Future<http.Response> get(String endpoint) async {
    final Uri uri = Uri.parse(endpoint);
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> getBytes(String endpoint) async {
    final Uri uri = Uri.parse(endpoint);
    final response = await _client.get(uri);
    return response;
  }

  void dispose() {
    _client.close();
  }
}
