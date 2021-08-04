import 'package:flutter/material.dart';
import 'package:flutter_weather/src/screens/settings_screen.dart';
import 'package:flutter_weather/src/screens/weather_screen.dart';
import 'package:flutter_weather/src/screens/home_page.dart';

class Routes {

  static final mainRoute = <String, WidgetBuilder>{
    // '/homepage':(context)=>HomePage(),
    '/home': (context) => WeatherScreen(),
    '/settings': (context) => SettingsScreen(),
  };
}
