import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ultimate_board.dart';

// ── Cartoon colour tokens ─────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFF1A1035);
  static const bgMid      = Color(0xFF221545);
  static const xBubble    = Color(0xFF4DDDFF);
  static const oBubble    = Color(0xFFFF6B9D);
  static const xDark      = Color(0xFF0099BB);
  static const oDark      = Color(0xFFCC3366);
  static const gold       = Color(0xFFFFD93D);
  static const goldDark   = Color(0xFFCC9900);
  static const green      = Color(0xFF6BCB77);
  static const cardBg     = Color(0xFF2A1F55);
  static const border     = Color(0xFF3D2F70);
  static const starYellow = Color(0xFFFFE566);
}

// ── Helper: cartoon card ──────────────────────────────────────────────────────
Widget _cartoonCard({
  required Widget child,
  Color fill = _C.cardBg,
  Color stroke = _C.border,
  double strokeW = 3,
  double radius = 20,
  List<BoxShadow>? shadows,
  EdgeInsets padding = const EdgeInsets.all(14),
}) =>
    Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: stroke, width: strokeW),
        boxShadow: shadows ??
            [
              BoxShadow(
                  color: stroke.withOpacity(0.6),
                  offset: const Offset(0, 5),
                  blurRadius: 0)
            ],
      ),
      child: child,
    );

// ── Bouncing dot loader ───────────────────────────────────────────────────────
class _BouncingDots extends StatefulWidget {
  final Color color;
  const _BouncingDots({required this.color});
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 500)));
    _anims = List.generate(
        3,
        (i) => Tween<double>(begin: 0, end: -8).animate(
            CurvedAnimation(parent: _ctrls[i], curve: Curves.easeInOut)));
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                  color: widget.color, shape: BoxShape.circle),
            ),
          ),
        );
      }),
    );
  }
}

// ── Floating star ─────────────────────────────────────────────────────────────
class _FloatingStar extends StatefulWidget {
  final double top, left, size;
  final int delayMs;
  const _FloatingStar(
      {required this.top,
      required this.left,
      required this.size,
      required this.delayMs});
  @override
  State<_FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<_FloatingStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1800 + widget.delayMs))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: -4, end: 4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: widget.top + _anim.value,
        left: widget.left,
        child: Opacity(
          opacity: 0.35,
          child: Icon(Icons.star_rounded,
              color: _C.starYellow, size: widget.size),
        ),
      ),
    );
  }
}

// ── Pulsing arrow ─────────────────────────────────────────────────────────────
class _PulsingArrow extends StatefulWidget {
  final Color color;
  const _PulsingArrow({required this.color});
  @override
  State<_PulsingArrow> createState() => _PulsingArrowState();
}

class _PulsingArrowState extends State<_PulsingArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(_anim.value, 0),
        child: Icon(Icons.chevron_right_rounded,
            color: widget.color, size: 20),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MAIN GAME SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bg, _C.bgMid, Color(0xFF2A1045)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient floating stars
              _FloatingStar(top: 60,  left: 14,  size: 14, delayMs: 0),
              _FloatingStar(top: 118, left: 345, size: 10, delayMs: 300),
              _FloatingStar(top: 200, left: 20,  size: 8,  delayMs: 600),
              _FloatingStar(top: 340, left: 350, size: 12, delayMs: 200),
              _FloatingStar(top: 490, left: 12,  size: 10, delayMs: 900),
              Column(
                children: [
                  const SizedBox(height: 4),
                  const _CartoonTopBar(),
                  const SizedBox(height: 10),
                  const _PlayerBannerRow(),
                  const SizedBox(height: 10),
                  const Expanded(child: _BoardArea()),
                  const SizedBox(height: 8),
                  const _BottomHintBubble(),
                  const SizedBox(height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _CartoonTopBar extends StatelessWidget {
  const _CartoonTopBar();

  Widget _iconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.55), width: 2),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                offset: const Offset(0, 3),
                blurRadius: 0)
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _iconBtn(
            icon: Icons.arrow_back_ios_rounded,
            color: _C.xBubble,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          Consumer<GameState>(
            builder: (_, g, __) => Column(
              children: [
                Text(
                  g.mode == GameMode.twoPlayer ? '2 PLAYERS' : 'VS AI',
                  style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.5),
                ),
                if (g.mode == GameMode.vsAI) _DiffBadge(g.difficulty),
              ],
            ),
          ),
          const Spacer(),
          Consumer<GameState>(
            builder: (_, g, __) => _iconBtn(
              icon: Icons.refresh_rounded,
              color: _C.gold,
              onTap: g.isAIThinking ? null : g.newGame,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final Difficulty d;
  const _DiffBadge(this.d);
  @override
  Widget build(BuildContext context) {
    const colors  = [_C.green, _C.gold, _C.oBubble];
    const labels  = ['😊  Easy', '🤔  Medium', '😈  Hard'];
    final c = colors[d.index];
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.6), width: 1.5),
      ),
      child: Text(labels[d.index],
          style: GoogleFonts.nunito(
              color: c, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

// ── Player banner row ─────────────────────────────────────────────────────────
class _PlayerBannerRow extends StatelessWidget {
  const _PlayerBannerRow();
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (_, game, __) {
        if (game.status != GameStatus.playing) {
          return _GameOverCard(game: game);
        }
        final isX = game.currentPlayer == CellState.x;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                  child: _PlayerChip(isX: true, active: isX, game: game)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('VS',
                    style: GoogleFonts.fredoka(
                        color: Colors.white30,
                        fontSize: 13,
                        letterSpacing: 2)),
              ),
              Expanded(
                  child: _PlayerChip(isX: false, active: !isX, game: game)),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final bool isX;
  final bool active;
  final GameState game;
  const _PlayerChip(
      {required this.isX, required this.active, required this.game});

  @override
  Widget build(BuildContext context) {
    final color = isX ? _C.xBubble : _C.oBubble;
    final dark  = isX ? _C.xDark   : _C.oDark;
    final isAI  = !isX && game.mode == GameMode.vsAI && game.isAIThinking;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.18) : _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: active ? color : _C.border,
            width: active ? 2.5 : 1.5),
        boxShadow: active
            ? [BoxShadow(
                color: color.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 0)]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Letter badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: active ? color : color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: dark, width: 2),
              boxShadow: active
                  ? [BoxShadow(
                      color: dark,
                      offset: const Offset(0, 3),
                      blurRadius: 0)]
                  : [],
            ),
            child: Center(
              child: Text(isX ? 'X' : 'O',
                  style: GoogleFonts.fredoka(
                      color: active ? Colors.white : color,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: isAI
                ? _BouncingDots(color: color)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _name(isX, game.mode),
                        style: GoogleFonts.nunito(
                          color: active ? color : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (active)
                        Text('Your turn!',
                            style: GoogleFonts.nunito(
                                color: color.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
          if (active) _PulsingArrow(color: color),
        ],
      ),
    );
  }

  String _name(bool isX, GameMode m) {
    if (m == GameMode.vsAI) return isX ? 'You' : 'AI Bot';
    return isX ? 'Player X' : 'Player O';
  }
}

// ── Game Over Card ────────────────────────────────────────────────────────────
class _GameOverCard extends StatelessWidget {
  final GameState game;
  const _GameOverCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final String emoji;
    final String title;
    final String sub;
    final Color color;
    final Color dark;

    if (game.status == GameStatus.xWins) {
      emoji = '🏆'; title = game.mode == GameMode.vsAI ? 'YOU WIN!' : 'X WINS!';
      sub   = game.mode == GameMode.vsAI ? 'Amazing strategy!' : 'Player X dominates!';
      color = _C.xBubble; dark = _C.xDark;
    } else if (game.status == GameStatus.oWins) {
      emoji = game.mode == GameMode.vsAI ? '🤖' : '🏆';
      title = game.mode == GameMode.vsAI ? 'AI WINS!' : 'O WINS!';
      sub   = game.mode == GameMode.vsAI ? 'Better luck next time!' : 'Player O dominates!';
      color = _C.oBubble; dark = _C.oDark;
    } else {
      emoji = '🤝'; title = "IT'S A DRAW!"; sub = 'Evenly matched!';
      color = _C.gold;    dark = _C.goldDark;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: _cartoonCard(
        fill: color.withOpacity(0.14),
        stroke: color,
        strokeW: 3,
        shadows: [BoxShadow(color: dark, offset: const Offset(0, 5), blurRadius: 0)],
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.fredoka(
                          color: color, fontSize: 22, letterSpacing: 1)),
                  Text(sub,
                      style: GoogleFonts.nunito(
                          color: color.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            GestureDetector(
              onTap: game.newGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dark, width: 2),
                  boxShadow: [
                    BoxShadow(color: dark, offset: const Offset(0, 4), blurRadius: 0)
                  ],
                ),
                child: Text('PLAY\nAGAIN',
                    style: GoogleFonts.fredoka(
                        color: Colors.white, fontSize: 13, height: 1.2),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Board Area ────────────────────────────────────────────────────────────────
class _BoardArea extends StatelessWidget {
  const _BoardArea();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _C.xBubble.withOpacity(0.07),
                  _C.oBubble.withOpacity(0.07),
                ],
              ),
              border: Border.all(
                  color: Colors.white.withOpacity(0.10), width: 2),
              boxShadow: [
                BoxShadow(
                    color: _C.xBubble.withOpacity(0.14),
                    blurRadius: 28,
                    offset: const Offset(-8, -8)),
                BoxShadow(
                    color: _C.oBubble.withOpacity(0.14),
                    blurRadius: 28,
                    offset: const Offset(8, 8)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: const UltimateBoardWidget(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Hint Bubble ────────────────────────────────────────────────────────
class _BottomHintBubble extends StatelessWidget {
  const _BottomHintBubble();
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (_, game, __) {
        if (game.status != GameStatus.playing) return const SizedBox.shrink();
        final free  = game.activeBoard == -1;
        final emoji = free ? '🌟' : '👉';
        final text  = free ? 'Free move — play anywhere!' : 'Play in the glowing board!';
        final color = free ? _C.gold : _C.green;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(text,
                  style: GoogleFonts.nunito(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        );
      },
    );
  }
}
