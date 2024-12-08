import 'package:ar_vis/joystick.dart';
import 'package:ar_vis/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;
  double _rotation = 0;
  double _xPosition = 0.0;
  double _zPosition = 0.0;
  final double step = 0.1;

  final NumberFormat _fixedLocaleNumberFormatter =
      NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  String get arStatusMessage {
    if (_isUnityArSupportedOnDevice == null) return "checking...";
    return _isUnityArSupportedOnDevice!
        ? "supported"
        : "not supported on this device";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Unity view
                      EmbedUnity(
                        onMessageFromUnity: _handleUnityMessage,
                      ),

                      // Joystick for movement
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: JoystickMove(
                          onChange: (details) {
                            setState(() {
                              _xPosition = (_xPosition + step * details.x)
                                  .clamp(-10, 10);
                              _zPosition = (_zPosition + step * (-details.y))
                                  .clamp(-10, 10);
                            });
                            _sendPositionToUnity();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // AR activation
                      Row(
                        children: [
                          Text("AR ($arStatusMessage)"),
                          Switch(
                            value: _isArSceneActive,
                            onChanged: (_isUnityArSupportedOnDevice == true)
                                ? _onArSceneSwitchChanged
                                : null,
                          ),
                        ],
                      ),
                      // Pause/Resume buttons
                      Row(
                        children: [
                          MyButton(
                            onTap: _onPausePressed,
                            iconData: Icons.pause,
                          ),
                          MyButton(
                            onTap: _onResumePressed,
                            iconData: Icons.play_arrow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rotation control slider
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.rotate_left),
                    ),
                    Expanded(
                      child: Slider(
                        min: -200,
                        max: 200,
                        value: _rotation,
                        onChanged: _onRotationChanged,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleUnityMessage(String data) {
    if (data == "scene_loaded") {
      _sendRotationToUnity(_rotation);
    } else if (data == "ar:true") {
      setState(() {
        _isUnityArSupportedOnDevice = true;
      });
    } else if (data == "ar:false") {
      setState(() {
        _isUnityArSupportedOnDevice = false;
      });
    }
  }

  void _onArSceneSwitchChanged(bool value) {
    sendToUnity(
      "SceneSwitcher",
      "SwitchToScene",
      _isArSceneActive
          ? "FlutterEmbedExampleScene"
          : "FlutterEmbedExampleSceneAR",
    );
    setState(() {
      _isArSceneActive = value;
    });
  }

  void _onRotationChanged(double value) {
    setState(() {
      _rotation = value;
    });
    _sendRotationToUnity(value);
  }

  void _onPausePressed() {
    pauseUnity();
    _enableARControl();
  }

  void _onResumePressed() {
    resumeUnity();
    _enableARControl();
  }

  void _sendRotationToUnity(double rotation) {
    sendToUnity(
      "FlutterLogo",
      "SetRotation",
      _fixedLocaleNumberFormatter.format(rotation),
    );
  }

  void _sendPositionToUnity() {
    sendToUnity("FlutterLogo", "SetControlledByFlutter", "true");
    sendToUnity("FlutterLogo", "SetPosition", "$_xPosition,0.0,$_zPosition");
  }

  void _sendScaleToUnity(double scale) {
    sendToUnity(
      "FlutterLogo",
      "SetScale",
      _fixedLocaleNumberFormatter.format(scale),
    );
  }

  void _enableARControl() {
    sendToUnity("FlutterLogo", "SetControlledByFlutter", "false");
  }
}
