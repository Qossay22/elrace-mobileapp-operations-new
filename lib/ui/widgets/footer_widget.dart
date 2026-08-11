import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
          child: Image.asset('assets/png/bottom.png'),
        ),
        const SizedBox.shrink(),
      ],
    );
  }
}
