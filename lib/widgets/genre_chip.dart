import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const GenreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? chipColor : Colors.white12,
            width: 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: chipColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: -2,
              ),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class GenreChipRow extends StatefulWidget {
  final List<String> genres;
  final void Function(int index)? onSelected;
  final int initialSelected;

  const GenreChipRow({
    super.key,
    required this.genres,
    this.onSelected,
    this.initialSelected = 0,
  });

  @override
  State<GenreChipRow> createState() => _GenreChipRowState();
}

class _GenreChipRowState extends State<GenreChipRow> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: widget.genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GenreChip(
          label: widget.genres[index],
          selected: _selected == index,
          onTap: () {
            setState(() => _selected = index);
            widget.onSelected?.call(index);
          },
        ),
      ),
    );
  }
}
