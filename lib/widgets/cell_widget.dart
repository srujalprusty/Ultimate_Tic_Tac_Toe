import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class CellWidget extends StatelessWidget {
  final int bigIdx;
  final int smallIdx;

  const CellWidget({
    super.key,
    required this.bigIdx,
    required this.smallIdx,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (_, game, __) {
        final cell      = game.cells[bigIdx][smallIdx];
        final playable  = game.isCellPlayable(bigIdx, smallIdx);
        final isLast    = game.lastMove != null &&
            game.lastMove![0] == bigIdx &&
            game.lastMove![1] == smallIdx;

        final cellColor = cell == CellState.x
            ? AppTheme.xColor
            : AppTheme.oColor;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: playable
              ? () => game.makeMove(bigIdx, smallIdx)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: isLast
                  ? cellColor.withOpacity(0.18)
                  : playable
                      ? AppTheme.surfaceVariant.withOpacity(0.6)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(child: _buildMark(cell, playable)),
          ),
        );
      },
    );
  }

  Widget? _buildMark(CellState cell, bool playable) {
    if (cell == CellState.none) {
      if (!playable) return null;
      return const Icon(Icons.add, size: 10, color: Color(0x22FFFFFF));
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Text(
        cell == CellState.x ? 'X' : 'O',
        style: TextStyle(
          color: cell == CellState.x ? AppTheme.xColor : AppTheme.oColor,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          height: 1,
        ),
      ),
    );
  }
}
