import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class JoystickMove extends StatefulWidget {
  final Function(StickDragDetails) onChange;
  const JoystickMove({Key? key, required this.onChange}) : super(key: key);

  @override
  State<JoystickMove> createState() => _JoystickMoveState();
}

class _JoystickMoveState extends State<JoystickMove> {
  final JoystickMode _joystickMode = JoystickMode.all;

  @override
  Widget build(BuildContext context) {
    return Joystick(
      stick: const JoystickStick(size: 20),
      base: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      mode: _joystickMode,
      listener: widget.onChange,
    );
  }
}
