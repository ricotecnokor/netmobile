import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/componente_result.dart';
import '../models/niveis_navegacao.dart';

class FiltroService {
  final http.Client _http = http.Client();
  final String baseUrl;

  FiltroService({required this.baseUrl});

  Future<int> obterQuantidadeTotal() async {
    final uri = Uri.parse('$baseUrl/tudoqtd');
    final res = await _http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body) as int;
    throw Exception('Falha ao obter quantidade: ${res.statusCode}');
  }

  Future<NiveisNavegacao> obterTudoPaginado(int skip, int take, {String texto = 'TNK-'}) async {
    final uri = Uri.parse('$baseUrl/tudofiltro/$texto/$skip/$take');
    final res = await _http.get(uri);
    if (res.statusCode == 200) {
      return NiveisNavegacao.fromJson(jsonDecode(res.body));
    }
    throw Exception('Falha ao carregar dados: ${res.statusCode}');
  }

  Future<NiveisNavegacao> obterTodos() async {
    final total = await obterQuantidadeTotal();
    return obterTudoPaginado(0, total);
  }

  Future<NiveisNavegacao> obterResumos(int nivel, String posicao) async {
    final uri = Uri.parse('$baseUrl/$nivel/$posicao');
    final res = await _http.get(uri);
    if (res.statusCode == 200) {
      return NiveisNavegacao.fromJson(jsonDecode(res.body));
    }
    throw Exception('Falha ao carregar resumos: ${res.statusCode}');
  }
}
