import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColores.superficie,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColores.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Franja de color arriba de la tarjeta
          Container(
            height: 4,
            width: 372,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              gradient: LinearGradient(
                colors: [AppColores.acento, AppColores.secundario],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: SizedBox(
              width: 340,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
