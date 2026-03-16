import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'ai_engine.dart';

enum CellState { none, x, o }

enum GameMode { twoPlayer, vsAI }

enum Difficulty { easy, medium, hard }

enum GameStatus { playing, xWins, oWins, draw }

// ---------------------------------------------------------------------------

class GameState extends ChangeNotifier {
  // cells[bigIdx][smallIdx]   bigIdx  = bigRow*3+bigCol   (0-8)
  //                            smallIdx = sRow*3+sCol       (0-8)
  List<List<CellState>> _cells = List.generate(
    9,
    (_) => List.filled(9, CellState.none),
  );

  List<CellState> _smallWinners = List.filled(9, CellState.none);
  List<bool> _smallDraws = List.filled(9, false);

  CellState _currentPlayer = CellState.x;
  int _activeBoard = -1; // -1 = any board (free move)
  GameStatus _status = GameStatus.playing;
  GameMode _mode = GameMode.twoPlayer;
  Difficulty _difficulty = Difficulty.medium;
  bool _isAIThinking = false;

  List<int>? _lastMove; // [bigIdx, smallIdx]
  List<int>? _winningLine; // indices in smallWinners forming the win

  // ── getters ──────────────────────────────────────────────────────────────

  List<List<CellState>> get cells => _cells;
  List<CellState> get smallWinners => _smallWinners;
  List<bool> get smallDraws => _smallDraws;
  CellState get currentPlayer => _currentPlayer;
  int get activeBoard => _activeBoard;
  GameStatus get status => _status;
  GameMode get mode => _mode;
  Difficulty get difficulty => _difficulty;
  bool get isAIThinking => _isAIThinking;
  List<int>? get lastMove => _lastMove;
  List<int>? get winningLine => _winningLine;

  // ── public API ───────────────────────────────────────────────────────────

  void setMode(GameMode m) {
    _mode = m;
    _reset();
  }

  void setDifficulty(Difficulty d) {
    _difficulty = d;
    notifyListeners();
  }

  void newGame() => _reset();

  bool isBoardActive(int bigIdx) {
    if (_status != GameStatus.playing) return false;
    if (_activeBoard != -1 && _activeBoard != bigIdx) return false;
    if (_smallWinners[bigIdx] != CellState.none) return false;
    if (_smallDraws[bigIdx]) return false;
    return true;
  }

  bool isCellPlayable(int bigIdx, int smallIdx) {
    if (_isAIThinking) return false;
    if (!isBoardActive(bigIdx)) return false;
    return _cells[bigIdx][smallIdx] == CellState.none;
  }

  Future<void> makeMove(int bigIdx, int smallIdx) async {
    if (!isCellPlayable(bigIdx, smallIdx)) return;
    HapticFeedback.lightImpact();
    _applyMove(bigIdx, smallIdx, _currentPlayer);
    notifyListeners();

    if (_status == GameStatus.playing &&
        _mode == GameMode.vsAI &&
        _currentPlayer == CellState.o) {
      await _runAI();
    }
  }

  // ── private ───────────────────────────────────────────────────────────────

  void _reset() {
    _cells = List.generate(9, (_) => List.filled(9, CellState.none));
    _smallWinners = List.filled(9, CellState.none);
    _smallDraws = List.filled(9, false);
    _currentPlayer = CellState.x;
    _activeBoard = -1;
    _status = GameStatus.playing;
    _isAIThinking = false;
    _lastMove = null;
    _winningLine = null;
    notifyListeners();
  }

  void _applyMove(int bigIdx, int smallIdx, CellState player) {
    _cells[bigIdx][smallIdx] = player;
    _lastMove = [bigIdx, smallIdx];

    // ── update small board ────────────────────────────────────────────────
    final smallResult = _checkWinnerOf(_cells[bigIdx]);
    if (smallResult.winner != CellState.none) {
      _smallWinners[bigIdx] = smallResult.winner;
    } else if (!_cells[bigIdx].contains(CellState.none)) {
      _smallDraws[bigIdx] = true;
    }

    // ── check overall game ────────────────────────────────────────────────
    final bigResult = _checkWinnerOf(_smallWinners);
    if (bigResult.winner != CellState.none) {
      _status = bigResult.winner == CellState.x
          ? GameStatus.xWins
          : GameStatus.oWins;
      _winningLine = bigResult.line;
      return;
    }

    bool allDone = true;
    for (int i = 0; i < 9; i++) {
      if (_smallWinners[i] == CellState.none && !_smallDraws[i]) {
        allDone = false;
        break;
      }
    }
    if (allDone) {
      _status = GameStatus.draw;
      return;
    }

    // ── determine next active board ───────────────────────────────────────
    _activeBoard =
        (_smallWinners[smallIdx] == CellState.none && !_smallDraws[smallIdx])
        ? smallIdx
        : -1;

    // ── switch player ─────────────────────────────────────────────────────
    _currentPlayer = _currentPlayer == CellState.x ? CellState.o : CellState.x;
  }

  Future<void> _runAI() async {
    _isAIThinking = true;
    notifyListeners();

    // Small delay so the UI can paint before the isolate is spawned
    await Future.delayed(const Duration(milliseconds: 200));

    final move = await compute(
      computeAIMove,
      AIInput(
        cells: _cells.map((b) => b.map((c) => c.index).toList()).toList(),
        smallWinners: _smallWinners.map((c) => c.index).toList(),
        smallDraws: List<bool>.from(_smallDraws),
        activeBoard: _activeBoard,
        aiPlayer: CellState.o.index, // AI = O = 2
        difficulty: _difficulty.index,
      ),
    );

    _isAIThinking = false;

    if (move.isNotEmpty && _status == GameStatus.playing) {
      _applyMove(move[0], move[1], CellState.o);
    }
    notifyListeners();
  }

  // ── static helpers ────────────────────────────────────────────────────────

  static ({CellState winner, List<int>? line}) _checkWinnerOf(
    List<CellState> board,
  ) {
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
      final p = board[l[0]];
      if (p != CellState.none && p == board[l[1]] && p == board[l[2]]) {
        return (winner: p, line: l);
      }
    }
    return (winner: CellState.none, line: null);
  }
}
