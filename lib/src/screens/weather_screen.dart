import 'package:flutter/material.dart';
import 'package:flutter_weather/main.dart';
import 'package:flutter_weather/src/bloc/weather_event.dart';
import 'package:flutter_weather/src/bloc/weather_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/src/widgets/weather_widget.dart';
import '../bloc/weather_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  final weatherRepository;
  final String cityName;
  const WeatherScreen(
      {Key key, this.cityName, @required this.weatherRepository})
      : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherBloc _weatherBloc;
  String _cityName;
  String addCity;
  List<dynamic> newCityList;
  Animation<double> _fadeAnimation;
  AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
    _weatherBloc = BlocProvider.of<WeatherBloc>(context);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  addCityHandle(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      dynamic temp = prefs.getString(
        'cities',
      );
      newCityList = json.decode(temp) as List<dynamic>;
    } catch (err) {}
    newCityList.add(name);
    try {
      prefs.setString('cities', json.encode(newCityList));
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    ThemeData appTheme = AppStateContainer.of(context).theme;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Material(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(color: appTheme.primaryColor),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (_, WeatherState weatherState) {
                _fadeController.reset();
                _fadeController.forward();

                if (weatherState is WeatherLoaded) {
                  _cityName = weatherState.weather.cityName;
                  return WeatherWidget(
                    weather: weatherState.weather,
                  );
                } else if (weatherState is WeatherError ||
                    weatherState is WeatherEmpty) {
                  _fetchWeatherWithCity();
                } else if (weatherState is WeatherLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: appTheme.primaryColor,
                    ),
                  );
                }
                return Container(
                  child: Text('No city set'),
                );
              }),
            ),
          ),
        ));
  }

  _fetchWeatherWithCity() {
    _weatherBloc.add(FetchWeather(cityName: _cityName));
  }

  void _showLocationDeniedDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          ThemeData appTheme = AppStateContainer.of(context).theme;

          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Location is disabled :(',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('Enable!'),
                style: TextButton.styleFrom(
                  primary: appTheme.accentColor,
                  elevation: 1,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
