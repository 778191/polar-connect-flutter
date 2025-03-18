import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? body;
  final String title;

  const CustomScaffold({Key? key, this.body, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.1 * displayHeight,
        elevation: 0,
        centerTitle: true,
        backgroundColor: CustomColors.background,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: CustomColors.tertiary,
            fontWeight: FontWeight.w700,
            fontSize: 0.06 * displayWidth,
          ),
        ),
      ),
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: body!,
      ),
    );
  }
}
