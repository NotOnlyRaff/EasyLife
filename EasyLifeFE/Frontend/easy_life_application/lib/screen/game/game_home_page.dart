import 'package:easy_life_application/core/widgets/game/game_card.dart';
import 'package:easy_life_application/core/widgets/game/game_console_filter_chip.dart';
import 'package:easy_life_application/core/widgets/game/game_sort_chip.dart';
import 'package:easy_life_application/screen/game/game_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/screen/game/game_create_page.dart';
import 'package:easy_life_application/services/game/game_service.dart';

enum GameSortField { name, saleDate, purchaseDate, price, salePrice, margin }

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final GameService _gameService = GameService();
  final TextEditingController _searchController = TextEditingController();

  List<GameModel> _allGames = [];
  List<GameModel> _filteredGames = [];

  // 🔎 FILTRI
  bool _onlyActive = false;
  bool _filterPs5Primary = false;
  bool _filterPs5Secondary = false;
  bool _filterPs4Primary = false;
  bool _filterPs4Secondary = false;

  // ORDINAMENTO
  GameSortField _sortField = GameSortField.name;
  bool _sortAscending = true;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await _gameService.getAllGames();
      setState(() {
        _allGames = games;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Errore caricamento giochi: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onAddGamePressed() async {
    final created = await Navigator.of(context).push<GameModel?>(
      MaterialPageRoute(builder: (_) => const GameCreatePage()),
    );

    if (created != null) {
      await _loadGames();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    List<GameModel> result = _allGames.where((g) {
      // 🔎 SEARCH: nome, profilo, ordine, nazione, descrizione
      final matchesQuery =
          query.isEmpty ||
          g.gameName.toLowerCase().contains(query) ||
          g.gameProfileId.toLowerCase().contains(query) ||
          g.orderNumber.toLowerCase().contains(query) ||
          g.nation.toLowerCase().contains(query) ||
          g.description.toLowerCase().contains(query);

      // ✅ SOLO attivi?
      final matchesActive = !_onlyActive || g.isActive;

      // 🎮 Filtri PS4/PS5
      if (_filterPs5Primary && !g.isPS5PrimaryAvailable) return false;
      if (_filterPs5Secondary && !g.isPS5SecondaryAvailable) return false;
      if (_filterPs4Primary && !g.isPS4PrimaryAvailable) return false;
      if (_filterPs4Secondary && !g.isPS4SecondaryAvailable) return false;

      return matchesQuery && matchesActive;
    }).toList();

    // 📊 ORDINAMENTO
    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case GameSortField.name:
          cmp = a.gameName.toLowerCase().compareTo(b.gameName.toLowerCase());
          break;
        case GameSortField.saleDate:
          cmp = a.saleDate.compareTo(b.saleDate);
          break;
        case GameSortField.purchaseDate:
          cmp = a.purchaseDate.compareTo(b.purchaseDate);
          break;
        case GameSortField.price:
          cmp = a.price.compareTo(b.price);
          break;
        case GameSortField.salePrice:
          cmp = a.salePrice.compareTo(b.salePrice);
          break;
        case GameSortField.margin:
          final marginA = a.salePrice - a.cost;
          final marginB = b.salePrice - b.cost;
          cmp = marginA.compareTo(marginB);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    setState(() {
      _filteredGames = result;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE + ADD GAME
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Games',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: _onAddGamePressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Game'),
              ),
            ],
          ),
        ),

        // SUBTITLE: piccoli stats (tot / attivi)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Totali: ${_allGames.length} • Attivi: ${_allGames.where((g) => g.isActive).length}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ),

        const SizedBox(height: 8),

        // 🔍 SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: 'Cerca per nome, profilo, ordine, nazione...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.black.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: Pallete.accentBlue, width: 1.6),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // 🎛️ FILTRI: Active + console
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Solo attivi'),
                selected: _onlyActive,
                avatar: const Icon(Icons.circle, size: 18),
                onSelected: (val) {
                  setState(() => _onlyActive = val);
                  _applyFilters();
                },
              ),
              GameConsoleFilterChip(
                label: 'PS5 Prim.',
                selected: _filterPs5Primary,
                color: Colors.blueAccent,
                onSelected: (val) {
                  setState(() => _filterPs5Primary = val);
                  _applyFilters();
                },
              ),
              GameConsoleFilterChip(
                label: 'PS5 Sec.',
                selected: _filterPs5Secondary,
                color: Colors.blueAccent.shade100,
                onSelected: (val) {
                  setState(() => _filterPs5Secondary = val);
                  _applyFilters();
                },
              ),
              GameConsoleFilterChip(
                label: 'PS4 Prim.',
                selected: _filterPs4Primary,
                color: Colors.deepPurpleAccent,
                onSelected: (val) {
                  setState(() => _filterPs4Primary = val);
                  _applyFilters();
                },
              ),
              GameConsoleFilterChip(
                label: 'PS4 Sec.',
                selected: _filterPs4Secondary,
                color: Colors.deepPurpleAccent.shade100,
                onSelected: (val) {
                  setState(() => _filterPs4Secondary = val);
                  _applyFilters();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 📊 ORDINAMENTO – CHIP
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GameSortChip(
                      label: 'Nome',
                      selected: _sortField == GameSortField.name,
                      onTap: () {
                        setState(() {
                          _sortField = GameSortField.name;
                          _applyFilters();
                        });
                      },
                    ),
                    GameSortChip(
                      label: 'Vendita',
                      selected: _sortField == GameSortField.saleDate,
                      onTap: () {
                        setState(() {
                          _sortField = GameSortField.saleDate;
                          _applyFilters();
                        });
                      },
                    ),
                    GameSortChip(
                      label: 'Acquisto',
                      selected: _sortField == GameSortField.purchaseDate,
                      onTap: () {
                        setState(() {
                          _sortField = GameSortField.purchaseDate;
                          _applyFilters();
                        });
                      },
                    ),
                    GameSortChip(
                      label: 'Margine',
                      selected: _sortField == GameSortField.margin,
                      onTap: () {
                        setState(() {
                          _sortField = GameSortField.margin;
                          _applyFilters();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _sortAscending
                    ? 'Ordina crescente'
                    : 'Ordina decrescente',
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
                icon: Icon(
                  _sortAscending
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ),

        // 🔹 SEPARATORE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // LISTA
        Expanded(child: _buildBody()),
      ],
    );
  }

  // BODY: loading / error / lista
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_filteredGames.isEmpty) {
      return const Center(
        child: Text(
          'Nessun gioco trovato',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _filteredGames.length,
        itemBuilder: (context, index) {
          final game = _filteredGames[index];
          return GameCard(
            game: game,
            onTap: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => GameDetailPage(game: game)),
              );

              if (changed == true) {
                await _loadGames();
              }
            },
          );
        },
      ),
    );
  }
}
