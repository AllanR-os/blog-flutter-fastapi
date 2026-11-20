import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColores.acento : AppColores.superficie,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColores.acento : AppColores.borde,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppColores.fondo : AppColores.texto,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
