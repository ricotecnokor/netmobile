
import 'package:flutter/material.dart';
import '../models/produto_result.dart';

class ProductItemWidget extends StatelessWidget {
  final ProdutoResult produto;
  final VoidCallback onTap;

  const ProductItemWidget({
    Key? key,
    required this.produto,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          produto.descricao,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          produto.prefixo,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: onTap,
        ),
      ),
    );
  }
}
