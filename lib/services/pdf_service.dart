import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfService {
  final http.Client _client = http.Client();
  final String _baseUrl = "http://192.168.200.67:8004/api/Pdf";

  Future<String> downloadAndSavePdf(String identidade) async {
    try {
      final semPrefixo = identidade.replaceAll("TNK-", "");
      if (semPrefixo.isEmpty) throw Exception('Identidade inválida');

      if (semPrefixo.contains("FL")) {
        final parts = semPrefixo.split("FL");
        if (parts.length != 2) throw Exception('Formato inválido para PDF folhado');

        final numero = parts[0];
        final folha = parts[1];

        final url = "$_baseUrl/$numero/$folha";

        final response = await _client.get(Uri.parse(url));
        return _processarResposta(response, semPrefixo);
      } else {
        final url = "$_baseUrl/$semPrefixo";

        final response = await _client.get(Uri.parse(url));
        return _processarResposta(response, semPrefixo);
      }
    } catch (e) {
      throw 'Falha ao carregar PDF: ${e.toString().replaceAll("Exception: ", "")}';
    }
  }

  Future<String> _processarResposta(http.Response response, String nomeArquivo) async {
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$nomeArquivo.pdf');

      await file.writeAsBytes(response.bodyBytes, flush: true);

      return file.path;
    } else if (response.statusCode == 404) {
      throw 'PDF não encontrado para este item';
    } else {
      throw 'Sem desenho no servidor (${response.statusCode})';
    }
  }

  void dispose() {
    _client.close();
  }
}
