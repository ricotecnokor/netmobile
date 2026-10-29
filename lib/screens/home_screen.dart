import 'package:flutter/material.dart';
import 'filter_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/engenheiro_sem_fundo.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/tecnokor_full.png',
                            height: 64,
                            color: Colors.white,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/tecnokor_icon.png',
                              height: 64,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildCard(
                        context: context,
                        title: 'Produtos',
                        icon: Icons.shopping_bag,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductListScreen()),
                        ),
                      ),
                      _buildCard(
                        context: context,
                        title: 'Filtro',
                        icon: Icons.filter_list,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FilterScreen()),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Image by Freepik — https://www.freepik.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final iconColor = Theme.of(context).primaryColor;

    return SizedBox(
      width: 140,
      height: 140,
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
