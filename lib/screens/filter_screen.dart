import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/componente_result.dart';
import '../state/state_filtro.dart';
import '../services/filtro_service.dart';
import '../widgets/coluna_componentes_widget.dart';
import 'component_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const double _desktopBreakpoint = 760.0;

  late final FiltroService _service;
  final TextEditingController _searchCtrl = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.94);

  Map<int, List<ComponenteResult>> _niveis = {};
  List<ComponenteResult> _todosNivelZero = [];
  List<int> _ordemNiveis = [];
  bool _isLoading = true, _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _searchCtrl.text = 'TNK-';
    _searchCtrl.selection = const TextSelection.collapsed(offset: 4);

    _searchCtrl.addListener(_fixPrefix);

    _service = FiltroService(baseUrl: 'http://192.168.200.67:8004/api/componentes');
    _initWithState();
  }

  void _fixPrefix() {
    if (!_searchCtrl.text.startsWith('TNK-')) {
      _searchCtrl.text = 'TNK-';
    }
    if (_searchCtrl.selection.baseOffset < 4) {
      _searchCtrl.selection = const TextSelection.collapsed(offset: 4);
    }
  }

  Future<void> _initWithState() async {
    await _loadInitialData();
    if (!mounted) return;
    final state = context.read<StateFiltro>();
    if (state.marca != 'default') {
      await _handleSelection('${state.nivel}|${state.marca}');
      final idx = _ordemNiveis.indexOf(state.nivel);
      if (idx != -1 && _pageController.hasClients) {
        _pageController.jumpToPage(idx);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_fixPrefix);
    _searchCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final nav = await _service.obterTodos();
      setState(() {
        _niveis = Map<int, List<ComponenteResult>>.from(nav.niveis);
        _todosNivelZero = List<ComponenteResult>.from(nav.niveis[0] ?? []);
        _ordemNiveis = _niveis.keys.toList()..sort();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSelection(String input) async {
    final parts = input.split('|');
    final nivelOriginal = int.parse(parts[0]);
    final marcaRaw = parts[1].replaceFirst('TNK-', '');
    final state = context.read<StateFiltro>();

    final bool primeiraSelecao = (state.marca == 'default' && nivelOriginal == 0);

    final int nivelParaCarregar = primeiraSelecao ? 2 : nivelOriginal;
    state.load(nivelParaCarregar, marcaRaw);

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final nav = await _service.obterResumos(nivelOriginal, marcaRaw);

      setState(() {
        _niveis.removeWhere((k, _) => k > nivelOriginal);
        _niveis.addAll(nav.niveis);
        _ordemNiveis = _niveis.keys.toList()..sort();
      });

      if (primeiraSelecao) {
        final disponiveis = _ordemNiveis.where((l) => l > nivelOriginal).toList();
        final nivelReal = disponiveis.contains(2)
            ? 2
            : (disponiveis.isNotEmpty ? disponiveis.first : nivelOriginal);

        if (nivelReal != state.nivel) {
          state.load(nivelReal, marcaRaw);
        }

        final idx = _ordemNiveis.indexOf(nivelReal);
        if (idx != -1) {
          state.setCurrentPage(idx);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(idx);
          }
        }
      } else if (nivelOriginal > 0) {
        final next = nivelOriginal + 1;
        final idx = _ordemNiveis.indexOf(next);
        if (idx != -1) {
          state.setCurrentPage(idx);
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              idx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleOpen(String input) {
    final parts = input.split('|');
    final full = parts[1].startsWith('TNK-') ? parts[1] : 'TNK-${parts[1]}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComponentScreen(identidadeInicial: full),
      ),
    );
  }

  void _handleSearch(String txt) {
    final query = txt.replaceFirst(RegExp(r'^TNK-'), '').trim();
    if (query.isEmpty) {
      if (_todosNivelZero.isNotEmpty) {
        setState(() {
          _niveis = {0: List<ComponenteResult>.from(_todosNivelZero)};
          _ordemNiveis = [0];
        });
      } else {
        _loadInitialData();
      }
      return;
    }

    final baseList = _todosNivelZero.isNotEmpty ? _todosNivelZero : (_niveis[0] ?? []);
    final upperQuery = query.toUpperCase();
    final filtered = baseList
        .where((c) =>
            c.identidade.toUpperCase().contains(upperQuery) ||
            c.descricao.toUpperCase().contains(upperQuery))
        .toList();
    setState(() {
      _niveis = {0: filtered};
      _ordemNiveis = [0];
    });
  }

  void _resetAll() {
    context.read<StateFiltro>().reset();
    _searchCtrl.text = 'TNK-';
    _searchCtrl.selection = const TextSelection.collapsed(offset: 4);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _loadInitialData();
  }

  String _columnTitleForLevel(StateFiltro state, int nivel) {
    if (state.marca == 'default' && nivel == 0) {
      return 'TODOS';
    } else if (nivel == state.nivel) {
      return 'PESQUISADO';
    } else {
      return 'COMPONENTE';
    }
  }

  Widget _buildColumnCard({
    required StateFiltro state,
    required int nivel,
    required Color barColor,
  }) {
    final title = _columnTitleForLevel(state, nivel);
    final items = _niveis[nivel] ?? [];
    final isTargetLevel = state.marca != 'default' && nivel == state.nivel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTargetLevel ? barColor : Colors.grey.shade300,
          width: isTargetLevel ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isTargetLevel ? barColor.withValues(alpha: 0.25) : Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Nível $nivel',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ColunaComponentesWidget(
              nivel: nivel,
              resumos: items,
              selectedId: state.marca.startsWith('TNK-')
                  ? state.marca
                  : 'TNK-${state.marca}',
              onSelect: _handleSelection,
              onOpen: _handleOpen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLevelSelector(StateFiltro state, Color barColor) {
    if (_ordemNiveis.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _ordemNiveis.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, idx) {
            final nivel = _ordemNiveis[idx];
            final isSelectedPage = state.currentPage == idx;
            final label = 'Nível $nivel (${_niveis[nivel]?.length ?? 0})';
            return ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelectedPage ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              selected: isSelectedPage,
              selectedColor: barColor,
              backgroundColor: Colors.grey.shade200,
              onSelected: (_) {
                state.setCurrentPage(idx);
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    idx,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateFiltro>();
    final barColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: barColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          state.itemPesquisado,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reiniciar pesquisa',
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Digite o código ou descrição para filtrar...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _searchCtrl.text.length > 4
                          ? IconButton(
                              tooltip: 'Limpar filtro',
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.text = 'TNK-';
                                _searchCtrl.selection =
                                    const TextSelection.collapsed(offset: 4);
                                _handleSearch('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _handleSearch,
                    onSubmitted: _handleSearch,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(_errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _resetAll,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isWide =
                              constraints.maxWidth >= _desktopBreakpoint;

                          if (isWide) {
                            if (_ordemNiveis.length == 1) {
                              return Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 760),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 0, 12, 12),
                                    child: _buildColumnCard(
                                      state: state,
                                      nivel: _ordemNiveis.first,
                                      barColor: barColor,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 0, 10, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final nivel in _ordemNiveis)
                                    Expanded(
                                      child: _buildColumnCard(
                                        state: state,
                                        nivel: nivel,
                                        barColor: barColor,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              _buildCompactLevelSelector(state, barColor),
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _ordemNiveis.length,
                                  onPageChanged: (i) => state.setCurrentPage(i),
                                  itemBuilder: (_, idx) {
                                    final nivel = _ordemNiveis[idx];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildColumnCard(
                                        state: state,
                                        nivel: nivel,
                                        barColor: barColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
