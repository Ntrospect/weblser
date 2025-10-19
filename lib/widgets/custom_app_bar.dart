import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showLogo = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (showLogo)
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
          if (showLogo) const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      actions: actions,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0B1220),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
