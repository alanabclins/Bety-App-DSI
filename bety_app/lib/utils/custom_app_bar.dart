// custom_app_bar.dart
import 'package:bety_sprint1/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/utils/alert_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String mainTitle;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onBackButtonPressed;
  final bool showLogoutButton;

  CustomAppBar({
    this.mainTitle = '',
    this.subtitle = '',
    this.backgroundColor = const Color(0xFF0BAB7C),
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.onBackButtonPressed,
    this.showLogoutButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(kToolbarHeight + 120), // Ajuste conforme necessário
      child: Column(
        children: [
          Container(
            height: 60,
            color: backgroundColor,
            child: Row(
              children: [
                if (onBackButtonPressed != null && mainTitle != ' ')
                  Padding(
                    padding: EdgeInsets.all(
                        8.0), // Ajuste o padding para posicionar o ícone
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: iconColor),
                      onPressed: onBackButtonPressed ??
                          () => Navigator.of(context).pop(),
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
                if (showLogoutButton) // Exibe o ícone de logoff somente se showLogoutButton for true
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.logout, color: iconColor),
                      onPressed: () {
                        CustomAlertDialog.show(
                          context: context,
                          title: 'Logoff',
                          content:
                              'Tem certeza que deseja desconectar do aplicativo?',
                          onConfirm: () async {
                            await AuthService().signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                        );
                      },
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
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 120); // Ajuste conforme necessário
}
