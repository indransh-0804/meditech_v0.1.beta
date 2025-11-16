import 'package:flutter/material.dart';
import 'package:meditech_v1/app/route.dart';
import 'package:meditech_v1/app/theme.dart';
import 'package:meditech_v1/app/font.dart';
import 'package:meditech_v1/core/utils/size_config.dart';

class MediTech extends StatelessWidget {
  const MediTech({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Manrope", "Inter");
    MaterialTheme theme = MaterialTheme(textTheme);
    SizeConfig().init(context);
    return MaterialApp.router(
      routerConfig: goRouter,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      debugShowCheckedModeBanner: false,
      title: 'MediTech',
    );
  }
}
