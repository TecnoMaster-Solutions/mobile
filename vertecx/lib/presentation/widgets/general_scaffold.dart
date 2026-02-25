import 'package:flutter/material.dart';
import 'package:vertecx/presentation/widgets/components/header/header.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String iconPath;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.iconPath = "assets/icons/userP.png", // default icon
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Column(
        children: [
          HearderUser(
            title: title,
            iconPath: iconPath,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFB20000),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
