import 'package:flutter/material.dart';

class StateFiltro with ChangeNotifier {
  String _marca = 'default';
  int _nivel = 0;
  String _itemPesquisado = 'INÍCIO DA PESQUISA - Todas as peças';
  int _currentPage = 0;
  int _indexBusca = 0;
  int _intervalo = 10;

  String get marca => _marca;
  int get nivel => _nivel;
  String get itemPesquisado => _itemPesquisado;
  int get currentPage => _currentPage;
  int get indexBusca => _indexBusca;
  int get intervalo => _intervalo;

  void reset() {
    _marca = 'default';
    _nivel = 0;
    _itemPesquisado = 'INÍCIO DA PESQUISA - Todas as peças';
    _currentPage = 0;
    _indexBusca = 0;
    notifyListeners();
  }

  void load(int nivel, String marca) {
    _nivel = nivel;
    _marca = marca;
    _itemPesquisado = marca == 'default'
        ? 'INÍCIO DA PESQUISA - Todas as peças'
        : 'PESQUISA DA PART NUMBER: $marca';
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setIndexBusca(int index) {
    _indexBusca = index;
    notifyListeners();
  }
}