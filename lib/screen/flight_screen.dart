import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'flight/blocs/flight_details_bloc.dart';
import '../model/airport.dart';
import '../api/airport_lookup.dart';

class FlightScreen extends StatelessWidget {
	FlightScreen({this.airportLookup});
	
	final AirportLookup airportLookup;
	final String title = 'Flutter Flight';
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Color(0xFF068FFA),
				title: Text(title),
			),
			body: FlightStream(context),
		);
	}
	
	Widget FlightStream(BuildContext context) {
		final flightDetailsBloc = Provider.of<FlightDetailsBloc>(context);
		
		return StreamBuilder<Flight>(
			stream: flightDetailsBloc.flightStream,
			initialData: Flight.initialData(),
			builder: (context, snapshot) {
				return Container(
					decoration: BoxDecoration( // background
						gradient: LinearGradient(
							begin: Alignment.topCenter,
							end: Alignment.bottomCenter,
							colors: [ // 2 warna jadi gradient
								Color(0xFF068FFA),
								Color(0xFF89ED91),
							],
						),
					),
					padding: const EdgeInsets.all(8.0),
					child: SafeArea( // form
						child: Column(
							children: <Widget>[
								FlightDetailsCard( airportLookup: airportLookup, flightDetails: snapshot.data.details, flightDetailsBloc: flightDetailsBloc, ),
								SizedBox(
									width: double.infinity,
									child: RaisedButton(
										child: Text("SEARCH", style: TextStyle(color: Colors.white)),
										color: Colors.brown,
										onPressed: () {
											print('from code : ' + snapshot.data.details.from_code + ' to code: ' + snapshot.data.details.to_code);
										},
									),
								),
								Expanded(child: Container()),
							],
						),
					),
				);
			},
		);
	}
}

class VerticalSpacing extends SizedBox {
	VerticalSpacing({double height = 16.0}) : super(height: height);
}

class AirportWidget extends StatelessWidget {
	AirportWidget({ this.iconData, this.type, this.title, this.airport, this.onPressed, this.flightDetailsBloc });
	
	final IconData iconData;
	final String type;
	final String title;
	final Airport airport;
	final VoidCallback onPressed;
	final FlightDetailsBloc flightDetailsBloc;
	
	@override
	Widget build(BuildContext context) {
		final code = airport != null ? airport.airport_code : '';
		final detail = airport != null ? '${airport.airport_name} (${airport.airport_code})' : title;
		
		if (type == 'from_code') flightDetailsBloc.updateWith(from_code: code);
		else if (type == 'to_code') flightDetailsBloc.updateWith(to_code: code);
		
		return InkWell(
			onTap: onPressed,
			child: Padding(
				padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
				child: Row(
					mainAxisSize: MainAxisSize.max,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						Icon(iconData),
						SizedBox(width: 16.0),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									VerticalSpacing(height: 4.0),
									AutoSizeText( detail, style: TextStyle(fontSize: 16.0), minFontSize: 13.0, maxLines: 2, overflow: TextOverflow.ellipsis, ),
									// Divider(height: 1.0, color: Colors.black87),
								],
							),
						),
					],
				),
			),
		);
	}
}

class FlightDetailsCard extends StatelessWidget {
	FlightDetailsCard({ @required this.flightDetails, @required this.flightDetailsBloc, @required this.airportLookup, });
	
	final FlightDetails flightDetails;
	final FlightDetailsBloc flightDetailsBloc;
	final AirportLookup airportLookup;
	
	Future<Airport> _showSearch(BuildContext context) async {
		return await showSearch<Airport>(
			context: context,
			delegate: AirportSearchDelegate( airportLookup: airportLookup )
		);
	}
	
	void _selectDeparture(BuildContext context) async {
		final departure = await _showSearch(context);
		print(departure);
		flightDetailsBloc.updateWith(departure: departure);
	}
	
	void _selectArrival(BuildContext context) async {
		final arrival = await _showSearch(context);
		print(arrival);
		flightDetailsBloc.updateWith(arrival: arrival);
	}
	
	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: 4.0,
			child: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [
							Color(0x40068FFA),
							Color(0x4089ED91),
						],
					),
				),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						VerticalSpacing(),
						AirportWidget( iconData: Icons.flight_takeoff, type: 'from_code', title: '-- pilih keberangkatan --', airport: flightDetails.departure, onPressed: () => _selectDeparture(context), flightDetailsBloc: flightDetailsBloc ),
						VerticalSpacing(),
						AirportWidget( iconData: Icons.flight_land, type: 'to_code', title: '-- pilih tiba --', airport: flightDetails.arrival, onPressed: () => _selectArrival(context), flightDetailsBloc: flightDetailsBloc ),
						VerticalSpacing(),
					],
				),
			),
		);
	}
}

class AirportSearchDelegate extends SearchDelegate<Airport> {
	AirportSearchDelegate({ @required this.airportLookup });
	
	final AirportLookup airportLookup;
	
	@override
	Widget buildLeading(BuildContext context) {
		return IconButton(
			tooltip: 'Back',
			icon: AnimatedIcon( icon: AnimatedIcons.menu_arrow, progress: transitionAnimation, ),
			onPressed: () { close(context, null); },
		);
	}
	
	@override
	Widget buildSuggestions(BuildContext context) {
		return buildMatchingSuggestions(context);
	}
	
	@override
	Widget buildResults(BuildContext context) {
		return buildMatchingSuggestions(context);
	}
	
	Widget buildMatchingSuggestions(BuildContext context) {
		if (query.isEmpty) return Container();
		if (query.length < 3) return Container();
		
		final searched = airportLookup.searchString(query);
		
		if (searched.length == 0) return AirportSearchPlaceholder(title: 'No results');
		
		return ListView.builder(
			itemCount: searched.length,
			itemBuilder: (context, index) {
				return AirportSearchResultTile( airport: searched[index], searchDelegate: this, );
			},
		);
	}
	
	@override
	List<Widget> buildActions(BuildContext context) {
		return query.isEmpty ? [] : <Widget>[
			IconButton(
				tooltip: 'Clear',
				icon: const Icon(Icons.clear),
				onPressed: () { query = ''; showSuggestions(context); },
			)
		];
	}
}

class AirportSearchPlaceholder extends StatelessWidget {
	AirportSearchPlaceholder({@required this.title});
	final String title;
	
	@override
	Widget build(BuildContext context) {
		final ThemeData theme = Theme.of(context);
		return Center(
			child: Text( title, style: theme.textTheme.headline, textAlign: TextAlign.center, ),
		);
	}
}

class AirportSearchResultTile extends StatelessWidget {
	const AirportSearchResultTile({ @required this.airport, @required this.searchDelegate });
	
	final Airport airport;
	final SearchDelegate<Airport> searchDelegate;
	
	@override
	Widget build(BuildContext context) {
		final title = '${airport.airport_name} (${airport.airport_code})';
		final subtitle = '${airport.airport_city}, ${airport.airport_country}';
		final ThemeData theme = Theme.of(context);
		return ListTile(
			dense: true,
			title: Text( title, style: theme.textTheme.body2, textAlign: TextAlign.start, ),
			subtitle: Text( subtitle, style: theme.textTheme.body1, textAlign: TextAlign.start, ),
			onTap: () => searchDelegate.close(context, airport),
		);
	}
}