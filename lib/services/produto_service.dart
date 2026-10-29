
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto_result.dart';
import '../utils/constants.dart';

class ProdutoService {
  final http.Client _client;

  ProdutoService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  Future<List<ProdutoResult>> listarProdutos() async {
    final Uri uri = Uri.parse(Constants.produtosEndpoint);

    final http.Response response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((item) => ProdutoResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('erro ao buscar produtos: HTTP ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
