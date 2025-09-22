import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p2p_chat_android/page/login_page.dart';
import 'package:p2p_chat_android/sql/database_helper.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = await DatabaseHelper.newInstance();
  runApp(MyApp(dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp(this.dbHelper, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarTheme = AppBarTheme(centerTitle: false, elevation: 0, color: kPrimaryColor);
    return MaterialApp(
      title: appName,
      theme: ThemeData.dark().copyWith(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kContentColorLightTheme,
        appBarTheme: appBarTheme,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: kContentColorLightTheme),
        colorScheme: ColorScheme.dark().copyWith(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          error: kErrorColor,
        ),
      ),
      home: LoginPage(dbHelper: dbHelper),
    );
  }
}