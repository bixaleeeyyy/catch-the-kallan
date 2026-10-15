/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64 
 *
 * Este programa es software libre: puedes redistribuirlo y/o modificarlo
 * bajo los términos de la Licencia Pública General GNU publicada por
 * la Free Software Foundation, ya sea la versión 3 de la Licencia, o
 * (a tu elección) cualquier versión posterior.
 *
 * Este programa se distribuye con la esperanza de que sea útil,
 * pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
 * COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO PARTICULAR. Consulta la
 * Licencia Pública General GNU para más detalles.
 *
 * Deberías haber recibido una copia de la Licencia Pública General GNU
 * junto con este programa. Si no es así, consulta <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/common.dart';
import '../config/theme.dart';
import '../words.dart';
import 'create_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _goToCreateCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    game.currentLang = lang.currentLanguage;

    return Scaffold(
      floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // NUEVO: Botón de Continuar (Solo visible si hay categorías seleccionadas)
                if (game.selectedCategories.isNotEmpty) ...[
                  FloatingActionButton.extended(
                    heroTag: 'btn_continue',
                    backgroundColor: AppColors.accent,
                    onPressed: () {
                                      Navigator.pushNamed(context, '/players');
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.black),
                    label: Text(
                      lang.translate('players_btn_continue'),
                      style: const TextStyle(
                        fontFamily: 'Bungee',
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),

      body: Stack(
        children: [
          GameBackground(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lang.translate('txt_choose_theme'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Bungee',
                                fontSize: 32,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _goToCreateCategory,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // GRID DE CATEGORÍAS (Actualizado para selección múltiple)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      100,
                    ), // Padding inferior extra para los botones flotantes
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: game.allCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = game.allCategories[i];
                      final isCustom =
                          i >= getGameCategories(lang.currentLanguage).length;

                      // Comprobamos si la categoría actual está en la lista de seleccionadas
                      final isSelected = game.selectedCategories.any(
                        (c) => c.id == cat.id,
                      );

                      return GestureDetector(
                        onTap: () {
                                              game.toggleCategory(
                            cat,
                          ); // Usamos la nueva función toggle
                        },
                        onLongPress: isCustom
                            ? () => _showOptions(context, game, cat, lang)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            // Cambia el color de fondo y el borde si está seleccionado
                            color: isSelected
                                ? cat.color.withOpacity(0.4)
                                : cat.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : cat.color.withOpacity(0.5),
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: cat.color.withOpacity(0.6),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat.icon,
                                    style: const TextStyle(fontSize: 50),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Bungee',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${cat.words.length} ${lang.translate('txt_cards')}",
                                    style: const TextStyle(
                                      fontFamily: 'YoungSerif',
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              // Icono de Check en la esquina superior derecha
                              if (isSelected)
                                const Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    GameProvider game,
    Category cat,
    LanguageProvider lang,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgBottom,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accent),
              title: Text(
                lang.translate('btn_edit'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'YoungSerif',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateCategoryScreen(categoryToEdit: cat),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text(
                lang.translate('btn_delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'YoungSerif',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                game.deleteCustomCategory(cat.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
