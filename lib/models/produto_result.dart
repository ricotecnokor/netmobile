
class ProdutoResult {
  final String prefixo;
  final String descricao;

  ProdutoResult({
    required this.prefixo,
    required this.descricao,
  });

  factory ProdutoResult.fromJson(Map<String, dynamic> json) {
    return ProdutoResult(
      prefixo: json['prefixo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
    );
  }
}
