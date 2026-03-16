import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'small_board.dart';

class UltimateBoardWidget extends StatelessWidget {
  const UltimateBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (i) => SmallBoardWidget(bigIdx: i)),
      ),
    );
  }
}
