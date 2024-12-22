import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:beauty_from_the_seoul_mobile/authentication/screens/welcome.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Beauty From The Seoul',
        theme: ThemeData(
          fontFamily: 'TT',
          scaffoldBackgroundColor: const Color(0xFFfcfaf3),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF071a58),
            primary: const Color(0xFF071a58),
          ),
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(color: Colors.white),
            ),
          ),
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate, // Add this delegate
        ],
        supportedLocales: const [
          Locale('en', ''), // Add supported locales here
        ],
        home: const WelcomePage(),
      ),
    );
  }
}