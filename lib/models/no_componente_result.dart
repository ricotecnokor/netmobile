import 'componente_result.dart';

class NoComponenteResult {
  final ComponenteResult componente;
  final List<ComponenteResult> pais;
  final List<ComponenteResult> filhos;

  NoComponenteResult({
    required this.componente,
    required this.pais,
    required this.filhos,
  });

  factory NoComponenteResult.fromJson(Map<String, dynamic> json) {
    final componenteJson =
        (json['componente'] as Map<String, dynamic>?) ?? json;
    final paisJsonList = json['pais'] as List<dynamic>? ?? [];
    final filhosJsonList = json['filhos'] as List<dynamic>? ?? [];

    return NoComponenteResult(
      componente: ComponenteResult.fromJson(componenteJson),
      pais: paisJsonList
          .map((e) => ComponenteResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      filhos: filhosJsonList
          .map((e) => ComponenteResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
