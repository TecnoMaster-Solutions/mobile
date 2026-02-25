import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AppDialogs {
  static void showConfirmChangeStatus({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      customHeader: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 43,
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
      title: title,
      desc: message,
      btnCancelText: "Cancelar",
      btnOkText: "Acepto",
      btnCancelOnPress: () {},
      btnOkOnPress: onConfirm,
    ).show();
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
