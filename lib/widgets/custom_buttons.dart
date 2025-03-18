import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccentButton extends StatelessWidget {
  const AccentButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.width,
      this.height});

  final String text;
  final Function()? onPressed;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CustomColors.tertiary,
        borderRadius: BorderRadius.circular(0.04 * displayWidth),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: CustomColors.background,
            fontSize: 0.05 * displayWidth,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class WhiteButton extends StatelessWidget {
  const WhiteButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = true,
    this.width,
    this.height,
  });

  final String text;
  final Function()? onPressed;
  final bool outlined;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: outlined
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(0.04 * displayWidth),
              border: Border.all(color: CustomColors.tertiary),
              color: CustomColors.background)
          : null,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: CustomColors.tertiary,
            fontSize: 0.04 * displayWidth,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CustomCardColumn extends StatelessWidget {
  const CustomCardColumn(
      {super.key,
      required this.icon,
      required this.text,
      required this.onPressed,
      this.width,
      this.height});

  final IconData icon;
  final String text;
  final Function()? onPressed;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.065 * displayWidth),
        color: CustomColors.secondary,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            icon,
            color: CustomColors.tertiary,
            size: 30,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: CustomColors.tertiary,
              fontSize: 0.035 * displayWidth,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ),
    );
  }
}

class CustomCardRow extends StatelessWidget {
  const CustomCardRow({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.premium,
  });

  final IconData icon;
  final String text;
  final Function()? onPressed;
  final double? width;
  final double? height;
  final bool? premium;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.065 * displayWidth),
        color: CustomColors.secondary,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(children: [
          Expanded(
            flex: 5,
            child: Row(children: [
              SizedBox(
                width: 0.03 * displayWidth,
              ),
              Icon(
                icon,
                color: CustomColors.tertiary,
                size: 30,
              ),
              SizedBox(
                width: 0.03 * displayWidth,
              ),
              Text(
                text,
                style: GoogleFonts.roboto(
                  color: CustomColors.tertiary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (premium ?? false)
                Row(children: [
                  SizedBox(
                    width: 0.03 * displayWidth,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.02 * displayWidth,
                          vertical: 0.01 * displayWidth),
                      decoration: BoxDecoration(
                        color: CustomColors.background,
                        borderRadius:
                            BorderRadius.circular(0.05 * displayWidth),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              color: CustomColors.tertiary, size: 25),
                          SizedBox(
                            width: 0.01 * displayWidth,
                          ),
                          Text(
                            'Premium',
                            style: GoogleFonts.roboto(
                              color: CustomColors.tertiary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )),
                ]),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.chevron_right,
                color: CustomColors.tertiary,
                size: 30,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.connected,
    this.width,
    this.height,
    this.batteryLevel,
  });

  final IconData icon;
  final String text;
  final Function()? onPressed;
  final double? width;
  final double? height;
  final bool connected;
  final int? batteryLevel;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.02 * displayWidth),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.065 * displayWidth),
        color: CustomColors.secondary,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(children: [
          Expanded(
            flex: 5,
            child: Row(children: [
              SizedBox(
                width: 0.03 * displayWidth,
              ),
              Icon(
                icon,
                color: CustomColors.tertiary,
                size: 30,
              ),
              SizedBox(
                width: 0.03 * displayWidth,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.roboto(
                      color: CustomColors.tertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (batteryLevel != null && connected)
                    Text(
                      'Battery: ' + batteryLevel.toString() + '%',
                      style: GoogleFonts.roboto(
                        color: CustomColors.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                connected ? Icons.bluetooth_audio_outlined : null,
                color: CustomColors.tertiary,
                size: 30,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.07 * displayWidth),
      child: Card(
        color: CustomColors.secondary,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 0.2 * displayHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.065 * displayWidth),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.01 * displayHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 100,
                color: CustomColors.tertiary,
              ),
              SizedBox(height: 0.05 * displayHeight),
              Text(
                text,
                style: GoogleFonts.roboto(
                  color: CustomColors.tertiary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
