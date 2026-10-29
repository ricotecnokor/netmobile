import 'componente_result.dart';

class NiveisNavegacao {
  final Map<int, List<ComponenteResult>> niveis;

  NiveisNavegacao(this.niveis);

  factory NiveisNavegacao.fromJson(Map<String, dynamic> json) {
    final raw = json['niveis'] as Map<String, dynamic>;
    final map = <int, List<ComponenteResult>>{};
    raw.forEach((k, v) {
      map[int.parse(k)] = (v as List)
          .map((e) => ComponenteResult.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return NiveisNavegacao(map);
  }
}
