// custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String mainTitle;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onBackButtonPressed;

  CustomAppBar({
    required this.mainTitle,
    required this.subtitle,
    this.backgroundColor = const Color(0xFF0BAB7C),
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 120), // Ajuste conforme necessário
      child: Column(
        children: [
          Container(
            color: backgroundColor,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0), // Ajuste o padding para posicionar o ícone
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: iconColor),
                    onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      mainTitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Bety', // Título fixo
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 120); // Ajuste conforme necessário
}