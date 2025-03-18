import 'package:polar_connect/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_scaffold.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() {
    return _MainMenuState();
  }
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double cardSeparation = 0.045 * displayWidth;

    return CustomScaffold(
        title: 'Main Menu',
        body: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 0.07 * displayWidth,
                vertical: 0.05 * displayHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(children: [
                  CustomCardRow(
                    height: 0.08 * displayHeight,
                    icon: Icons.folder,
                    text: 'File Browser',
                    onPressed: () => Navigator.pushNamed(context, '/files'),
                  ),
                  SizedBox(height: cardSeparation),
                  CustomCardRow(
                    height: 0.08 * displayHeight,
                    icon: Icons.bluetooth_audio_outlined,
                    text: 'Polar Connect',
                    onPressed: () => Navigator.pushNamed(context, '/polar'),
                  ),
                ]),
              ],
            )));
  }
}
