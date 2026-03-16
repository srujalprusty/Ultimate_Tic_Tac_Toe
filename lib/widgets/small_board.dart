import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'cell_widget.dart';

class SmallBoardWidget extends StatelessWidget {
  final int bigIdx;

  const SmallBoardWidget({super.key, required this.bigIdx});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (_, game, __) {
        final active      = game.isBoardActive(bigIdx);
        final winner      = game.smallWinners[bigIdx];
        final draw        = game.smallDraws[bigIdx];
        final isWinBoard  = game.winningLine?.contains(bigIdx) ?? false;
        final isPlaying   = game.status == GameStatus.playing;

        Color borderColor = AppTheme.border;
        double borderWidth = 1;

        if (active && isPlaying) {
          borderColor  = AppTheme.activeBoard;
          borderWidth  = 2;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: active && isPlaying
                ? AppTheme.activeBoard.withOpacity(0.04)
                : AppTheme.surface,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(6),
            boxShadow: active && isPlaying
                ? [
                    BoxShadow(
                      color: AppTheme.activeBoard.withOpacity(0.25),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                // 3×3 grid of cells
                GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(3),
                  children: List.generate(
                    9,
                    (smallIdx) =>
                        CellWidget(bigIdx: bigIdx, smallIdx: smallIdx),
                  ),
                ),
                // Overlay when board is decided
                if (winner != CellState.none || draw)
                  _decidedOverlay(winner, draw, isWinBoard),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _decidedOverlay(CellState winner, bool draw, bool isWinBoard) {
    final Color color;
    final String label;

    if (draw) {
      color = AppTheme.textSecondary;
      label = '·';
    } else {
      color = winner == CellState.x ? AppTheme.xColor : AppTheme.oColor;
      label = winner == CellState.x ? 'X' : 'O';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Container(
        decoration: BoxDecoration(
          color: draw
              ? AppTheme.surfaceVariant.withOpacity(0.88)
              : color.withOpacity(isWinBoard ? 0.28 : 0.18),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:      color,
              fontSize:   isWinBoard ? 44 : 36,
              fontWeight: FontWeight.w900,
              height:     1,
            ),
          ),
        ),
      ),
    );
  }
}
