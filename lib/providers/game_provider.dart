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

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/constants.dart';
import '../words.dart';

class Player {
  String id;
  String name;
  bool isLocked;
  String role;
  Player({
    required this.id,
    this.name = '',
    this.isLocked = true,
    this.role = 'civilian',
  });
}

enum GameStatus { setup, playing, finished }

class GameProvider with ChangeNotifier {
  String currentLang = 'en';
  List<Category> _customCategories = [];

  List<Category> get allCategories => [
    ...getGameCategories(currentLang),
    ..._customCategories,
  ];

  List<Player> players = [];

  // --- SELECCIÓN MÚLTIPLE DE CATEGORÍAS ---
  List<Category> selectedCategories = [];

  String get selectedCategoriesName {
    if (selectedCategories.isEmpty) return "";
    if (selectedCategories.length == 1) return selectedCategories.first.name;
    return "MIX (${selectedCategories.length})";
  }

  String secretWord = '';
  // Hint shown to the impostor (theme name, or first letter for the Random theme)
  String impostorHint = '';

  // --- EL CORAZÓN DEL CAOS (Global Random) ---
  // Se instancia UNA SOLA VEZ al abrir la app para asegurar entropía pura
  // en cada partida, evitando que se repitan los roles numéricos.
  final Random _random = Random();

  int impostorCount = 1;
  int initialTimeSeconds = GameConstants.defaultTimeSeconds;
  int currentTurnIndex = 0;

  Timer? _timer;
  int remainingSeconds = 0;
  bool isTimerRunning = false;
  GameStatus status = GameStatus.setup;

  GameProvider() {
    _initGame();
    _loadCustomCategories();
  }

  void _initGame() {
    for (int i = 0; i < 4; i++) {
      _addEmptyPlayer();
    }
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(GameConstants.prefsCustomCategories);
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _customCategories = decoded
            .map((item) => Category.fromMap(item))
            .toList();
        notifyListeners();
      } catch (e) {
        debugPrint("Error load: $e");
      }
    }
  }

  Future<void> saveCustomCategory(Category cat, {bool isEdit = false}) async {
    if (isEdit) {
      final idx = _customCategories.indexWhere((c) => c.id == cat.id);
      if (idx != -1) _customCategories[idx] = cat;
    } else {
      _customCategories.add(cat);
    }
    await _persistCategories();
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    selectedCategories.removeWhere((c) => c.id == id);
    await _persistCategories();
    notifyListeners();
  }

  Future<void> _persistCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _customCategories.map((c) => c.toMap()).toList(),
    );
    await prefs.setString(GameConstants.prefsCustomCategories, encoded);
  }

  void _addEmptyPlayer() {
    players.add(
      Player(
        id:
            DateTime.now().microsecondsSinceEpoch.toString() +
            _random.nextInt(999).toString(),
      ),
    );
    notifyListeners();
  }

  void addPlayer() {
    _addEmptyPlayer();
    notifyListeners();
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updatePlayer(String id, {String? name}) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx != -1 && name != null) players[idx].name = name;
  }

  void toggleCategory(Category cat) {
    final index = selectedCategories.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      selectedCategories.removeAt(index);
    } else {
      selectedCategories.add(cat);
    }
    notifyListeners();
  }

  void adjustImpostors(int delta) {
    int max = (players.where((p) => p.isLocked).length / 2).floor();
    if (max < 1) max = 1;

    int newVal = impostorCount + delta;
    if (newVal >= 1 && newVal <= max) {
      impostorCount = newVal;
      notifyListeners();
    }
  }

  void adjustTime(int delta) {
    int newVal = initialTimeSeconds + delta;
    if (newVal >= 60) {
      initialTimeSeconds = newVal;
      notifyListeners();
    }
  }

  // --- GAMEPLAY Y ALGORITMO CAOS ---
  void startGame() {
    if (selectedCategories.isEmpty) return;

    final lockedPlayers = players.where((p) => p.isLocked).toList();
    if (lockedPlayers.length < GameConstants.minPlayers) return;

    _timer?.cancel();
    isTimerRunning = false;

    // 1. Limpieza total de roles (todos regresan a civiles)
    for (var p in players) {
      p.role = 'civilian';
    }

    // 2. Extraer TODAS las palabras de las categorías seleccionadas
    // Give a default name to players who left it empty
    for (int i = 0; i < players.length; i++) {
      if (players[i].name.trim().isEmpty) {
        players[i].name = 'Player ${i + 1}';
      }
    }

    final List<MapEntry<String, Category>> pool = [];
    for (var cat in selectedCategories) {
      for (var w in cat.words) {
        pool.add(MapEntry(w, cat));
      }
    }

    final picked = pool[_random.nextInt(pool.length)];
    secretWord = picked.key;
    if (picked.value.hint.trim().isNotEmpty) {
      impostorHint = picked.value.hint.trim();
    } else if (picked.value.id == 'mix') {
      impostorHint = 'Starts with "${secretWord.trim()[0].toUpperCase()}"';
    } else {
      impostorHint = 'Theme: ${picked.value.name}';
    }

    // 3. Algoritmo Caos V2 (Sorteo de Impostores sin repetir patrón)
    int safeImpostorCount = impostorCount;
    if (safeImpostorCount >= lockedPlayers.length) safeImpostorCount = 1;

    List<int> bagOfIndices = List.generate(lockedPlayers.length, (i) => i);

    for (int i = 0; i < safeImpostorCount; i++) {
      if (bagOfIndices.isEmpty) break;

      // Usamos la semilla global que nunca se reinicia
      int randomIndex = _random.nextInt(bagOfIndices.length);
      int luckyPlayerIndex = bagOfIndices[randomIndex];

      lockedPlayers[luckyPlayerIndex].role = 'impostor';
      bagOfIndices.removeAt(randomIndex); // Sacamos al jugador de la bolsa
    }

    // 4. Reinicio de turno y estado
    currentTurnIndex = 0;
    status = GameStatus.playing;
    remainingSeconds = initialTimeSeconds;

    // Feedback general (lo sienten todos porque el cel está en la mesa)
    notifyListeners();
  }

  void nextTurn() {
    currentTurnIndex++;
    notifyListeners();
  }

  Player getCurrentPlayer() {
    final active = players.where((p) => p.isLocked).toList();
    if (currentTurnIndex >= active.length) currentTurnIndex = 0;
    return active[currentTurnIndex];
  }

  void startTimer() {
    WakelockPlus.enable();
    isTimerRunning = true;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;

        notifyListeners();
      } else {
        stopTimer(finished: true);
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer({bool finished = false}) {
    _timer?.cancel();
    isTimerRunning = false;
    WakelockPlus.disable();
    if (finished) {
      status = GameStatus.finished;
    }
    notifyListeners();
  }

  void finishGameAndVote() {
    _timer?.cancel();
    isTimerRunning = false;
    WakelockPlus.disable();
    notifyListeners();
  }

  void addExtraTime() {
    remainingSeconds += 60;
    status = GameStatus.playing;
    if (isTimerRunning) {
      _timer?.cancel();
      startTimer();
    }
    notifyListeners();
  }

  // --- OPTIMIZACIÓN: Revancha Rápida ---
  void prepareNewMatch() {
    _timer?.cancel();
    WakelockPlus.disable();
    isTimerRunning = false;

    // Al llamar startGame, garantizamos una limpieza interna de roles,
    // nueva extracción de palabras y nuevos impostores usando el Random global.
    startGame();
  }

  // --- OPTIMIZACIÓN: Hard Reset al Menú ---
  void exitGame() {
    _cleanup();
    selectedCategories.clear(); // Limpia los temas
    players.clear(); // Elimina los jugadores
    _initGame(); // Crea 4 jugadores vacíos de nuevo
    status = GameStatus.setup;
    notifyListeners();
  }

  void _cleanup() {
    _timer?.cancel();
    WakelockPlus.disable();
    status = GameStatus.setup;
    isTimerRunning = false;
    currentTurnIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
