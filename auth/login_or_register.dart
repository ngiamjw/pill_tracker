import "package:flutter/material.dart";
import "package:pill_tracker/pages/login_page.dart";
import "package:pill_tracker/pages/register_page.dart";

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool setLoginPage = true;

  void togglePages() {
    setState(() {
      setLoginPage = !setLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (setLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
