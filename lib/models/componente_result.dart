class ComponenteResult {
  final String identidade;
  final String descricao;

  ComponenteResult({
    required this.identidade,
    required this.descricao,
  });

  factory ComponenteResult.fromJson(Map<String, dynamic> json) {
    return ComponenteResult(
      identidade: (json['identidade'] ?? json['marca']) as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
    );
  }
}
