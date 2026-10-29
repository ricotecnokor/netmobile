import 'package:flutter/material.dart';
import '../models/componente_result.dart';

typedef OnSelect = void Function(String identidade);
typedef OnOpen = void Function(String identidade);

class ColunaComponentesWidget extends StatelessWidget {
  final int nivel;
  final List<ComponenteResult> resumos;
  final String selectedId;
  final OnSelect onSelect;
  final OnOpen onOpen;

  const ColunaComponentesWidget({
    Key? key,
    required this.nivel,
    required this.resumos,
    required this.selectedId,
    required this.onSelect,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (resumos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum componente encontrado.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: resumos.length,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemBuilder: (context, i) {
        final c = resumos[i];
        final full = c.identidade.startsWith('TNK-')
            ? c.identidade
            : 'TNK-${c.identidade}';
        final isSelected = full == selectedId;

        return Card(
          elevation: isSelected ? 3 : 1,
          color: isSelected ? Colors.amber.shade50 : Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelect('$nivel|$full'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.widgets_outlined,
                      size: 18,
                      color: isSelected ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          full,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFF303030),
                          ),
                        ),
                        if (c.descricao.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            c.descricao,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Visualizar componente',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 20,
                      color: Color(0xFF424242),
                    ),
                    onPressed: () => onOpen('$nivel|$full'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
