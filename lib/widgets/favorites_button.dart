import 'package:flutter/material.dart';

class FavoritesButton extends StatelessWidget {
  final VoidCallback onPressed;

  FavoritesButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.favorite),
      onPressed: onPressed,
    );
  }
}
