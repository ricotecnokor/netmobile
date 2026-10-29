import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../models/componente_result.dart';
import '../models/no_componente_result.dart';
import '../services/componente_service.dart';
import '../services/pdf_service.dart';

class _PageImageData {
  final Uint8List bytes;
  final double aspectRatio;

  _PageImageData({required this.bytes, required this.aspectRatio});
}

class ComponentScreen extends StatefulWidget {
  final String identidadeInicial;

  const ComponentScreen({Key? key, required this.identidadeInicial})
      : super(key: key);

  @override
  State<ComponentScreen> createState() => _ComponentScreenState();
}

class _ComponentScreenState extends State<ComponentScreen> {
  final ComponenteService _compService = ComponenteService();
  final PdfService _pdfService = PdfService();

  late Future<NoComponenteResult> _futureNo;
  bool _arvoreAberta = false;
  bool _desenhoAberto = true;
  String _pdfPath = "";

  Future<_PageImageData>? _pageImageFuture;

  final TransformationController _transformationController =
  TransformationController();

  bool _isScaling = false;

  static const double _zoomMaximo = 100.0;
  static const double _zoomStep = 1.5;

  static const Color _cinzaEscuro = Color(0xFF424242);
  static const Color _cinzaClaro = Color(0xFFF5F5F5);
  static const Color _cinzaMedio = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _futureNo = _carregarNoComponente(widget.identidadeInicial);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<NoComponenteResult> _carregarNoComponente(String prefixoComTnk) async {
    final no = await _compService.obterComponente(prefixoComTnk);

    final downloadedPath =
    await _pdfService.downloadAndSavePdf(no.componente.identidade);

    setState(() {
      _pdfPath = downloadedPath;
      _transformationController.value = Matrix4.identity();
      _pageImageFuture = null;
    });

    return no;
  }

  Future<_PageImageData> _renderizarPrimeiraPagina(
      String path, double availableWidth, double availableHeight) async {
    final document = await PdfDocument.openFile(path);
    final page = await document.getPage(1);

    final double pageWidth = page.width;
    final double pageHeight = page.height;

    final double dpi = MediaQuery.of(context).devicePixelRatio;
    const int oversample = 4;

    final int targetPixelWidth = (availableWidth * dpi * oversample).toInt();
    final int targetPixelHeight = (availableHeight * dpi * oversample).toInt();

    final double scaleFactorW = targetPixelWidth / pageWidth;
    final double scaleFactorH = targetPixelHeight / pageHeight;
    final double scaleFactor =
    (scaleFactorW < scaleFactorH) ? scaleFactorW : scaleFactorH;

    final PdfPageImage? pageImage = await page.render(
      width: pageWidth * scaleFactor,
      height: pageHeight * scaleFactor,
    );

    await page.close();
    await document.close();

    if (pageImage == null) {
      throw Exception("Falha ao renderizar a primeira página do PDF.");
    }

    final double aspectRatio = pageHeight / pageWidth;
    return _PageImageData(bytes: pageImage.bytes, aspectRatio: aspectRatio);
  }

  void _abrirFilho(ComponenteResult filho) {
    final identidadeFull = "TNK-${filho.identidade}";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComponentScreen(identidadeInicial: identidadeFull),
      ),
    );
  }

  void _zoomIn() {
    final newScale = _transformationController.value.getMaxScaleOnAxis() * _zoomStep;
    if (newScale <= _zoomMaximo) {
      _transformationController.value = Matrix4.identity()
        ..scale(newScale, newScale, 1.0);
    }
  }

  void _zoomOut() {
    final newScale = _transformationController.value.getMaxScaleOnAxis() / _zoomStep;
    if (newScale >= 1.0) {
      _transformationController.value = Matrix4.identity()
        ..scale(newScale, newScale, 1.0);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NoComponenteResult>(
      future: _futureNo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Carregando...", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.grey[800],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Erro ao carregar", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.grey[800],
            ),
            body: Center(child: Text("Erro: ${snapshot.error}")),
          );
        }

        final no = snapshot.data!;
        final String identidadeRaiz = "TNK-${no.componente.identidade}";
        final String nomeRaiz = no.componente.descricao;
        final barColor = Theme.of(context).primaryColor;

        return Scaffold(
          appBar: AppBar(
            title: Text(nomeRaiz.toUpperCase(),
                style: const TextStyle(color: Colors.black)),
            backgroundColor: barColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              ListView(
                physics: _isScaling
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Container(
                    color: _cinzaClaro,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      "PART NUMBER: $identidadeRaiz",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _cinzaEscuro,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (no.filhos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ExpansionTile(
                        title: const Text(
                          "ÁRVORE DO PRODUTO",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        initiallyExpanded: _arvoreAberta,
                        onExpansionChanged: (val) {
                          setState(() {
                            _arvoreAberta = val;
                          });
                        },
                        maintainState: true,
                        backgroundColor: _cinzaMedio,
                        collapsedBackgroundColor: _cinzaMedio,
                        children: [
                          Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                for (var filho in no.filhos)
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      "TNK-${filho.identidade}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _cinzaEscuro,
                                      ),
                                    ),
                                    subtitle: Text(
                                      filho.descricao,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => _abrirFilho(filho),
                                    ),
                                    onTap: () => _abrirFilho(filho),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ExpansionTile(
                      title: const Text(
                        "DESENHO",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      initiallyExpanded: _desenhoAberto,
                      onExpansionChanged: (val) {
                        setState(() {
                          _desenhoAberto = val;
                        });
                      },
                      maintainState: true,
                      backgroundColor: _cinzaMedio,
                      collapsedBackgroundColor: _cinzaMedio,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (_pageImageFuture == null) {
                              final double availableWidth = constraints.maxWidth;
                              final double availableHeight =
                                  MediaQuery.of(context).size.height * 0.9;

                              _pageImageFuture = _renderizarPrimeiraPagina(
                                _pdfPath,
                                availableWidth,
                                availableHeight,
                              );
                            }

                            return FutureBuilder<_PageImageData>(
                              future: _pageImageFuture,
                              builder: (context, snapshotImg) {
                                final double availableWidth = constraints.maxWidth;

                                if (snapshotImg.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height:
                                    MediaQuery.of(context).size.height * 0.9,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                } else if (snapshotImg.hasError) {
                                  return Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height:
                                    MediaQuery.of(context).size.height * 0.9,
                                    child: Center(
                                      child: Text(
                                          "Erro ao renderizar PDF: ${snapshotImg.error}"),
                                    ),
                                  );
                                } else {
                                  final data = snapshotImg.data!;
                                  final bytes = data.bytes;
                                  final aspectRatio = data.aspectRatio;
                                  final double heightInicial =
                                      availableWidth * aspectRatio;

                                  return GestureDetector(
                                    onScaleStart: (_) {
                                      setState(() {
                                        _isScaling = true;
                                      });
                                    },
                                    onScaleEnd: (_) {
                                      setState(() {
                                        _isScaling = false;
                                      });
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      width: double.infinity,
                                      height: heightInicial,
                                      child: InteractiveViewer(
                                        transformationController:
                                        _transformationController,
                                        boundaryMargin: const EdgeInsets.all(20),
                                        minScale: 1.0,
                                        maxScale: _zoomMaximo,
                                        panEnabled: true,
                                        scaleEnabled: true,
                                        child: Image.memory(
                                          bytes,
                                          width: availableWidth,
                                          height: heightInicial,
                                          fit: BoxFit.fill,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),

              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'zoomIn',
                      mini: true,
                      onPressed: _zoomIn,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.zoom_in, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'zoomOut',
                      mini: true,
                      onPressed: _zoomOut,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.zoom_out, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'resetZoom',
                      mini: true,
                      onPressed: _resetZoom,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.refresh, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}