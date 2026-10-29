
import 'componente_result.dart';

class ResultRaiz {
  final String titulo;
  final List<ComponenteResult> lista;

  ResultRaiz({
    required this.titulo,
    required this.lista,
  });

  factory ResultRaiz.fromJson(Map<String, dynamic> json) {
    final List<dynamic> listaJson = (json['lista'] as List<dynamic>?) ?? [];
    return ResultRaiz(
      titulo: json['titulo'] as String? ?? '',
      lista: listaJson
          .map((item) =>
          ComponenteResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
