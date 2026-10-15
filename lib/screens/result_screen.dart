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
import '../widgets/inputs.dart';
import '../config/theme.dart';
import 'category_screen.dart';
import 'reveal_screen.dart';

class ResultScreen extends StatelessWidget {
  final Player votedPlayer;
  const ResultScreen({super.key, required this.votedPlayer});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final bool isImpostor = votedPlayer.role == 'impostor';

    final bgColor = isImpostor
        ? const Color(0xFF00C853)
        : const Color(0xFFD50000);

    final winnerText = isImpostor
        ? lang.translate('result_win_civilians')
        : lang.translate('result_win_impostor');

    final game = Provider.of<GameProvider>(context, listen: false);
    final impostorNames = game.players
        .where((p) => p.role == 'impostor')
        .map((p) => p.name)
        .join(', ');

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              winnerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Bungee',
                fontSize: 24,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'THE WORD WAS',
                        style: TextStyle(
                          fontFamily: 'YoungSerif',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          game.secretWord.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Bungee',
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        impostorNames.contains(',')
                            ? 'THE IMPOSTORS WERE'
                            : 'THE IMPOSTOR WAS',
                        style: const TextStyle(
                          fontFamily: 'YoungSerif',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        impostorNames.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.bgBottom,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Hard Reset al salir
                        Provider.of<GameProvider>(
                          context,
                          listen: false,
                        ).exitGame();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                          (r) => false,
                        );
                      },
                      child: Text(
                        lang.translate('result_btn_exit'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: BouncyButton(
                      text: lang.translate('result_btn_play_again'),
                      color: AppColors.accent,
                      onPressed: () {
                        // Preparamos la partida internamente (sorteo de roles y palabra)
                        Provider.of<GameProvider>(
                          context,
                          listen: false,
                        ).prepareNewMatch();

                        // Saltamos directo al ciclo de juego
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RevealScreen(),
                          ),
                          (r) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
