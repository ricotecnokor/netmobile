
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/no_componente_result.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class ComponenteService {
  final ApiService _apiService;

  ComponenteService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<NoComponenteResult> obterComponente(String identidade) async {
    final url = "${Constants.componenteEndpoint}/$identidade";
    final http.Response response = await _apiService.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
      jsonDecode(response.body) as Map<String, dynamic>;
      return NoComponenteResult.fromJson(jsonMap);
    } else {
      throw Exception('Erro ao obter componente: HTTP ${response.statusCode}');
    }
  }
}
