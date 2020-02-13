import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'screen/flight_screen.dart';

import 'model/airport.dart';
import 'api/airport_lookup.dart';
import 'screen/flight/blocs/flight_details_bloc.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	
	final start = DateTime.now();
	
	List<Airport> airports = await AirportDataReader.load('assets/data/airport_world_wide.json');
	
	final elapsed = DateTime.now().difference(start);
	print('Loaded airports data in $elapsed');
	
	runApp(MyApp(airportLookup: AirportLookup(airports: airports)));
}

class AirportDataReader {
	static Future<List<Airport>> load(String path) async {
		final data = await rootBundle.loadString(path);
		
		// return data.split('\n').map((line) => Airport.fromLine(line)).where((airport) => airport != null).toList();
		return json.decode(data).map<Airport>((json) => Airport.fromJson(json)).toList();
	}
}

class MyApp extends StatelessWidget {
	MyApp({this.airportLookup});
	
	final AirportLookup airportLookup;
	final String title = 'Flutter Flight';
	
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Flight CO2 calculator',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: StatefulProvider<FlightDetailsBloc>(
				valueBuilder: (context) => FlightDetailsBloc(),
				onDispose: (context, bloc) => bloc.dispose(),
				child: FlightScreen(airportLookup: airportLookup),
			),
		);
	}
}
