import 'package:flutter/material.dart';

class HearderUser extends StatelessWidget {
  final String title;
  final String iconPath;
   final double titleSize;
   final Widget? leading;

  const HearderUser({
    super.key,
    required this.title,
    required this.iconPath,
    this.titleSize = 32,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 69,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        color: Color(0xfff3f3f3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Texto centrado
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFB20000),
              ),
            ),
          ),
          
          // Botón de retroceso
          if (leading != null)
            Positioned(
              left: 10,
              child: leading!,
            ),

          // Imagen alineada a la derecha
          Positioned(
            right: 25,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                iconPath,
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
