import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UK Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String city = "London";
  String temperature = "";
  String description = "";
  String icon = "";
  bool loading = false;

  static const String apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

  Future<void> fetchWeather() async {
    setState(() {
      loading = true;
    });

    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$city,uk&appid=$apiKey&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = data["main"]["temp"].toString();
        description = data["weather"][0]["description"];
        icon = data["weather"][0]["icon"];
        loading = false;
      });
    } else {
      setState(() {
        description = "City not found";
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UK Weather"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Enter UK city",
              ),
              onChanged: (value) {
                city = value;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchWeather,
              child: const Text("Get Weather"),
            ),
            const SizedBox(height: 30),
            if (loading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  if (temperature.isNotEmpty)
                    Text(
                      "$temperature°C",
                      style: const TextStyle(fontSize: 40),
                    ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (icon.isNotEmpty)
                    Image.network(
                        "https://openweathermap.org/img/wn/$icon@2x.png"),
                ],
              )
          ],
        ),
      ),
    );
  }
}
