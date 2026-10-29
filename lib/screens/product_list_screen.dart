
import 'package:flutter/material.dart';
import '../models/produto_result.dart';
import '../models/result_raiz.dart';
import '../services/produto_service.dart';
import '../services/raiz_service.dart';
import 'component_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProdutoService _produtoService = ProdutoService();
  final RaizService _raizService = RaizService();

  late Future<List<ProdutoResult>> _futureProdutos;
  final Map<String, Future<ResultRaiz>> _cacheRaiz = {};

  static const Color _cinzaClaro = Color(0xFFF5F5F5);
  static const Color _cinzaEscuro = Color(0xFF424242);
  static const Color _cinzaMedio  = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _futureProdutos = _produtoService.listarProdutos();
  }

  Future<ResultRaiz> _getRaizParaPrefixo(String prefixoComTnk) {
    return _cacheRaiz.putIfAbsent(
      prefixoComTnk,
          () => _raizService.carregarRaiz(prefixoComTnk),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: barColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Produtos', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<List<ProdutoResult>>(
        future: _futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final produtos = snapshot.data ?? [];
          if (produtos.isEmpty) {
            return const Center(child: Text("Nenhum produto encontrado"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.transparent,
                child: ExpansionTile(
                  backgroundColor: _cinzaMedio,
                  collapsedBackgroundColor: _cinzaMedio,
                  tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    produto.descricao,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Colors.black,
                  ),
                  onExpansionChanged: (isOpen) {
                    if (isOpen) {
                      _getRaizParaPrefixo(produto.prefixo);
                    }
                  },
                  children: [
                    Container(
                      color: Colors.white,
                      child: FutureBuilder<ResultRaiz>(
                        future: _getRaizParaPrefixo(produto.prefixo),
                        builder: (context, snapshotRaiz) {
                          if (snapshotRaiz.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child:
                              Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshotRaiz.hasError) {
                            return ListTile(
                              title: Text(
                                "Erro ao carregar: ${snapshotRaiz.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final raiz = snapshotRaiz.data!;
                          final filhos = raiz.lista;
                          if (filhos.isEmpty) {
                            return const ListTile(
                              title: Text("Nenhum item encontrado"),
                            );
                          }

                          return Column(
                            children: filhos.map((filho) {
                              final fullId = filho.identidade.startsWith('TNK-')
                                  ? filho.identidade
                                  : 'TNK-${filho.identidade}';
                              return ListTile(
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                title: Text(
                                  fullId,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _cinzaEscuro,
                                  ),
                                ),
                                subtitle: Text(filho.descricao),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_new,
                                      color: _cinzaEscuro),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ComponentScreen(
                                          identidadeInicial: fullId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
