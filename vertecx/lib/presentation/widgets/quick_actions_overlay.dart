import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuickAction {
  final String label;
  final String assetPath;
  final VoidCallback onTap;
  const QuickAction({required this.label, required this.assetPath, required this.onTap});
}

class QuickActionsOverlay extends StatelessWidget {
  const QuickActionsOverlay({
    super.key,
    required this.actions,
    required this.onClose,
    required this.bottomOffset,
    this.cornerRadius = 22,
    this.hPad = 16,
  });

  final List<QuickAction> actions;
  final VoidCallback onClose;
  final double bottomOffset;
  final double cornerRadius;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    const wine = Color(0xFF5C0F0F);
    const red  = Color(0xFFB20000);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(onTap: onClose, child: Container(color: Colors.black45)),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomOffset,
          child: Material(
            color: wine,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cornerRadius),
              topRight: Radius.circular(cornerRadius),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (_, i) {
                      final a = actions[i];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () { onClose(); a.onTap(); },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    a.assetPath,
                                    width: 34,
                                    height: 34,
                                    colorFilter: const ColorFilter.mode(red, BlendMode.srcIn),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    a.label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: red, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
