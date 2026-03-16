// AI engine – runs inside Flutter's compute() isolate.
// All data uses plain Dart primitives so it passes through SendPort safely.

class AIInput {
  /// cells[bigIdx][smallIdx] — 0 = none, 1 = X, 2 = O
  final List<List<int>> cells;
  final List<int> smallWinners; // 0 / 1 / 2
  final List<bool> smallDraws;
  final int activeBoard; // −1 = free move
  final int aiPlayer; // 2 = O (always)
  final int difficulty; // 0 easy | 1 medium | 2 hard

  const AIInput({
    required this.cells,
    required this.smallWinners,
    required this.smallDraws,
    required this.activeBoard,
    required this.aiPlayer,
    required this.difficulty,
  });
}

/// Top-level function required by compute().
List<int> computeAIMove(AIInput input) => AIEngine(input).bestMove();

// ---------------------------------------------------------------------------

class AIEngine {
  final List<List<int>> _cells;
  final List<int> _sw; // smallWinners
  final List<bool> _sd; // smallDraws
  final int _ab; // activeBoard
  final int _ai; // aiPlayer  (2)
  final int _hu; // humanPlayer (1)
  final int _diff;

  static const _depths = [1, 4, 6]; // easy / medium / hard

  AIEngine(AIInput inp)
    : _cells = inp.cells.map((b) => List<int>.from(b)).toList(),
      _sw = List<int>.from(inp.smallWinners),
      _sd = List<bool>.from(inp.smallDraws),
      _ab = inp.activeBoard,
      _ai = inp.aiPlayer,
      _hu = inp.aiPlayer == 1 ? 2 : 1,
      _diff = inp.difficulty;

  // ── public ───────────────────────────────────────────────────────────────

  List<int> bestMove() {
    final moves = _validMoves(_cells, _sw, _sd, _ab);
    if (moves.isEmpty) return [];

    if (_diff == 0) {
      // Easy – random
      moves.shuffle();
      return moves.first;
    }

    final depth = _depths[_diff];
    int best = -1000000;
    List<int> pick = moves.first;
    moves.shuffle();

    for (final m in moves) {
      final s = _next(_cells, _sw, _sd, m[0], m[1], _ai);
      final v = _minimax(
        s.$1,
        s.$2,
        s.$3,
        s.$4,
        depth - 1,
        -1000000,
        1000000,
        false,
      );
      if (v > best) {
        best = v;
        pick = m;
      }
    }
    return pick;
  }

  // ── private ───────────────────────────────────────────────────────────────

  int _minimax(
    List<List<int>> cells,
    List<int> sw,
    List<bool> sd,
    int ab,
    int depth,
    int alpha,
    int beta,
    bool maximising,
  ) {
    final w = _winner(sw);
    if (w == _ai) return 10000 + depth;
    if (w == _hu) return -10000 - depth;

    final moves = _validMoves(cells, sw, sd, ab);
    if (moves.isEmpty) return 0;
    if (depth == 0) return _eval(cells, sw);

    if (maximising) {
      int best = -1000000;
      for (final m in moves) {
        final s = _next(cells, sw, sd, m[0], m[1], _ai);
        final v = _minimax(
          s.$1,
          s.$2,
          s.$3,
          s.$4,
          depth - 1,
          alpha,
          beta,
          false,
        );
        if (v > best) best = v;
        if (best > alpha) alpha = best;
        if (beta <= alpha) break;
      }
      return best;
    } else {
      int best = 1000000;
      for (final m in moves) {
        final s = _next(cells, sw, sd, m[0], m[1], _hu);
        final v = _minimax(
          s.$1,
          s.$2,
          s.$3,
          s.$4,
          depth - 1,
          alpha,
          beta,
          true,
        );
        if (v < best) best = v;
        if (best < beta) beta = best;
        if (beta <= alpha) break;
      }
      return best;
    }
  }

  // Returns (newCells, newSW, newSD, nextActiveBoard)
  (List<List<int>>, List<int>, List<bool>, int) _next(
    List<List<int>> cells,
    List<int> sw,
    List<bool> sd,
    int big,
    int small,
    int player,
  ) {
    final c2 = cells.map((b) => List<int>.from(b)).toList();
    final w2 = List<int>.from(sw);
    final d2 = List<bool>.from(sd);

    c2[big][small] = player;

    final bw = _winner(c2[big]);
    if (bw != 0) {
      w2[big] = bw;
    } else if (!c2[big].contains(0)) {
      d2[big] = true;
    }

    final next = (w2[small] != 0 || d2[small]) ? -1 : small;
    return (c2, w2, d2, next);
  }

  List<List<int>> _validMoves(
    List<List<int>> cells,
    List<int> sw,
    List<bool> sd,
    int ab,
  ) {
    final result = <List<int>>[];
    for (int big = 0; big < 9; big++) {
      if (ab != -1 && ab != big) continue;
      if (sw[big] != 0 || sd[big]) continue;
      for (int small = 0; small < 9; small++) {
        if (cells[big][small] == 0) result.add([big, small]);
      }
    }
    return result;
  }

  int _winner(List<int> b) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final l in lines) {
      final p = b[l[0]];
      if (p != 0 && p == b[l[1]] && p == b[l[2]]) return p;
    }
    return 0;
  }

  int _eval(List<List<int>> cells, List<int> sw) {
    int score = _evalBoard(sw) * 10;
    for (int i = 0; i < 9; i++) score += _evalBoard(cells[i]);
    return score;
  }

  int _evalBoard(List<int> b) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    int score = 0;
    for (final l in lines) {
      int ai = 0, hu = 0;
      for (final i in l) {
        if (b[i] == _ai)
          ai++;
        else if (b[i] == _hu)
          hu++;
      }
      if (hu == 0) score += ai * ai;
      if (ai == 0) score -= hu * hu;
    }
    return score;
  }
}
