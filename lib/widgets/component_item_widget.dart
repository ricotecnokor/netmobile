
import 'package:flutter/material.dart';
import '../models/componente_result.dart';

class ComponentItemWidget extends StatelessWidget {
  final ComponenteResult componente;
  final VoidCallback onTap;

  const ComponentItemWidget({
    Key? key,
    required this.componente,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(
          componente.descricao,
          style: const TextStyle(fontSize: 15),
        ),
        subtitle: Text(
          componente.identidade,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: onTap,
        ),
      ),
    );
  }
}
