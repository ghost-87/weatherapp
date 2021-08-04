import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/src/screens/weather_screen.dart';
import 'package:flutter_weather/src/bloc/weather_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'dart:developer';

class HomePage extends StatefulWidget {
  final weatherRepository;
  HomePage({Key key, @required this.weatherRepository}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List weatherList = [];
  List<Widget> sliders = [];
  dynamic cityList;
  List<dynamic> cityListList = [];
  final List<dynamic> addCityList = ['Kuala Lumpur', 'Bengaluru', 'Tokyo'];
  dynamic newCityName;

  @override
  void initState() {
    print('11111111111111');
    cityListHandler(addCityList);
    super.initState();
  }

  cityListHandler(addCityList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic temp5;
    try {
      temp5 = prefs.getString(
        'cities',
      );
    } catch (err) {}

    if (  temp5 == null) {
      print('empty');
      try {
        prefs.setString('cities', json.encode(addCityList));
      } catch (err) {}
    } else {
      print(' empty not');
      cityListList = json.decode(temp5) as List<dynamic>;
    }

    try {
      dynamic temp = prefs.getString(
        'cities',
      );
      cityListList = json.decode(temp) as List<dynamic>;
    } catch (err) {}
    weatherHandle(cityListList);
  }

  weatherHandle(apple) {
    print('apple');
    print(apple);
    var temp2 = apple;
    for (int i = 0; i < temp2.length; i++) {
      var temp = BlocProvider(
        create: (context) =>
            WeatherBloc(weatherRepository: widget.weatherRepository),
        child: WeatherScreen(
            cityName: temp2[i], weatherRepository: widget.weatherRepository),
      );
      weatherList.add(temp);
    }
    sliders = weatherList
        .map((item) => Container(
              child: item,
            ))
        .toList();
  }

  addCityHandle(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      dynamic temp = prefs.getString(
        'cities',
      );
      cityListList = json.decode(temp) as List<dynamic>;
    } catch (err) {}
    cityListList.add(name);
    try {
      prefs.setString('cities', json.encode(cityListList));
    } catch (err) {}

    weatherHandle(cityListList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            )
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<OptionsMenu>(
              child: Icon(
                Icons.more_vert,
                color: Colors.red,
              ),
              onSelected: this._onOptionMenuItemSelected,
              itemBuilder: (context) => <PopupMenuEntry<OptionsMenu>>[
                    PopupMenuItem<OptionsMenu>(
                      value: OptionsMenu.changeCity,
                      child: Text("Add city"),
                    ),
                    PopupMenuItem<OptionsMenu>(
                      value: OptionsMenu.settings,
                      child: Text("settings"),
                    ),
                  ])
        ],
      ),
      body: Container(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            enlargeCenterPage: true,
            scrollDirection: Axis.vertical,
            autoPlay: true,
          ),
          items: sliders,
        ),
      ),
    );
  }

  _onOptionMenuItemSelected(OptionsMenu item) {
    switch (item) {
      case OptionsMenu.changeCity:
        this._showCityChangeDialog();
        break;
      case OptionsMenu.settings:
        Navigator.of(context).pushNamed("/settings");
        break;
    }
  }

  void _showCityChangeDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Add city', style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text('ok'),
                style: TextButton.styleFrom(
                  primary: Colors.red,
                  elevation: 1,
                ),
                onPressed: () {
                  if (newCityName != null || newCityName.isnotempty()) {
                    addCityHandle(newCityName);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
            content: TextField(
              autofocus: true,
              onChanged: (text) {
                newCityName = text;
              },
              decoration: InputDecoration(
                  hintText: 'Name of your city',
                  hintStyle: TextStyle(color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      // _fetchWeatherWithLocation().catchError((error) {
                      // _fetchWeatherWithCity();
                      // }
                      // );
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Colors.black,
                      size: 16,
                    ),
                  )),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
          );
        });
  }
}
