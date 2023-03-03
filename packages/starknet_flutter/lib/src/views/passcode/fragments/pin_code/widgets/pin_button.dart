import 'package:flutter/material.dart';
import 'package:starknet_flutter/src/views/widgets/bouncing_button.dart';

// TODO: add alphabet
class PinButton extends StatelessWidget {
  final int number;
  final Function()? onTap;

  const PinButton({
    super.key,
    required this.number,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
