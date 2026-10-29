import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/componente_result.dart';
import '../models/result_raiz.dart';
import '../utils/constants.dart';

class RaizService {
  final http.Client _client;
  Future<List<ComponenteResult>>? _cacheTodosRaiz;

  RaizService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  Future<List<ComponenteResult>> _obterTodosRaiz() async {
    final Uri uri = Uri.parse(Constants.raizEndpoint);

    final http.Response response = await _client.get(uri);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic niveisRaw = decoded['niveis'];
        if (niveisRaw is Map<String, dynamic>) {
          final List<dynamic> nivelZero = (niveisRaw['0'] as List<dynamic>?) ?? [];
          return nivelZero
              .whereType<Map<String, dynamic>>()
              .map(ComponenteResult.fromJson)
              .toList();
        }

        if (decoded.containsKey('lista')) {
          return ResultRaiz.fromJson(decoded).lista;
        }
      }
    }

    return [];
  }

  Future<ResultRaiz> carregarRaiz(String prefixoComTnk) async {
    try {
      _cacheTodosRaiz ??= _obterTodosRaiz();
      final todos = await _cacheTodosRaiz!;

      final prefixoNormalizado = prefixoComTnk.startsWith('TNK-')
          ? prefixoComTnk.toUpperCase()
          : 'TNK-${prefixoComTnk.toUpperCase()}';

      final filtrados = todos.where((item) {
        final idNormalizado = item.identidade.startsWith('TNK-')
            ? item.identidade.toUpperCase()
            : 'TNK-${item.identidade.toUpperCase()}';
        return idNormalizado.startsWith(prefixoNormalizado);
      }).toList();

      return ResultRaiz(
        titulo: prefixoComTnk.replaceFirst('TNK-', ''),
        lista: filtrados,
      );
    } catch (_) {
      _cacheTodosRaiz = null;
      return ResultRaiz(titulo: '', lista: []);
    }
  }

  void dispose() {
    _client.close();
  }
}
