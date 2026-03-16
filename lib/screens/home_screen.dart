import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Difficulty _difficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF111820)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildTitle(context),
                const SizedBox(height: 32),
                _buildDecorBoard(),
                const Spacer(flex: 2),
                _buildModeButton(
                  context,
                  icon: Icons.people_rounded,
                  label: '2 Players',
                  subtitle: 'Pass & play with a friend',
                  color: AppTheme.xColor,
                  mode: GameMode.twoPlayer,
                ),
                const SizedBox(height: 16),
                _buildModeButton(
                  context,
                  icon: Icons.smart_toy_rounded,
                  label: 'vs AI',
                  subtitle: 'Challenge the computer',
                  color: AppTheme.oColor,
                  mode: GameMode.vsAI,
                ),
                const SizedBox(height: 28),
                _buildDifficultyPicker(),
                const Spacer(flex: 2),
                _buildHowToPlay(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── sections ───────────────────────────────────────────────────────────────

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'ULTIMATE',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
                letterSpacing: 10,
                fontWeight: FontWeight.w300,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'TIC-TAC-TOE',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.textPrimary,
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
                fontSize: 34,
              ),
        ),
      ],
    );
  }

  Widget _buildDecorBoard() {
    // Small illustrative board showing a mid-game position
    const marks = {0: 'X', 1: 'O', 3: 'X', 5: 'O', 8: 'X'};
    return SizedBox(
      width: 110,
      height: 110,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: 9,
        itemBuilder: (_, i) {
          final m = marks[i];
          return Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: m == null
                  ? null
                  : Text(
                      m,
                      style: TextStyle(
                        color: m == 'X' ? AppTheme.xColor : AppTheme.oColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required GameMode mode,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(context, mode),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          color: color,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: color.withOpacity(0.6), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyPicker() {
    return Column(
      children: [
        Text(
          'AI DIFFICULTY',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Difficulty.values.map((d) {
            final sel = d == _difficulty;
            final label =
                d.name[0].toUpperCase() + d.name.substring(1);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => setState(() => _difficulty = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.surfaceVariant,
                    border: Border.all(
                      color: sel
                          ? AppTheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: sel
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight: sel
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHowToPlay(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHowToPlay(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline_rounded,
              size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            'How to play',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  void _startGame(BuildContext context, GameMode mode) {
    final game = context.read<GameState>();
    game.setDifficulty(_difficulty);
    game.setMode(mode);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'How to Play',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final item in _rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                              fontSize: 14),
                        ),
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

  static const _rules = [
    ('🎯', 'The big board is a 3×3 grid of smaller 3×3 tic-tac-toe boards.'),
    ('📍',
        'Your move in a small board determines which small board your opponent must play in next.'),
    ('🏆', 'Win a small board by getting three in a row inside it.'),
    ('🌟',
        'Win the game by winning three small boards in a row on the big board.'),
    ('🆓',
        'If you are sent to a board that is already won or full, you may play anywhere.'),
  ];
}
