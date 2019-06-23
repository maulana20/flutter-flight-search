import 'dart:async';

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
			body: _Background(context),
		);
	}
	
	Widget _Background(BuildContext context) {
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
	AirportWidget({this.iconData, this.title, this.airport, this.onPressed});
	
	final IconData iconData;
	final Widget title;
	final Airport airport;
	final VoidCallback onPressed;
	
	@override
	Widget build(BuildContext context) {
		final airportDisplayName = airport != null ? '${airport.airport_name} (${airport.airport_code})' : 'Select...';
		// final airportDisplayName = airport != null ? '${airport.name} (${airport.iata})' : 'Select...';
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
									title,
									VerticalSpacing(height: 4.0),
									AutoSizeText( airportDisplayName, style: TextStyle(fontSize: 16.0), minFontSize: 13.0, maxLines: 2, overflow: TextOverflow.ellipsis, ),
									Divider(height: 1.0, color: Colors.black87),
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
	
	final Map<FlightClass, Widget> flightClassChildren = const <FlightClass, Widget>{
		FlightClass.economy: Text('Economy'),
		FlightClass.business: Text('Business'),
		FlightClass.first: Text('First'),
	};
	
	final Map<FlightType, Widget> flightTypeChildren = const <FlightType, Widget>{
		FlightType.oneWay: Text('One Way'),
		FlightType.twoWays: Text('Return'),
	};
	
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
						AirportWidget( iconData: Icons.flight_takeoff, title: Text('departing from'), airport: flightDetails.departure, onPressed: () => _selectDeparture(context) ),
						VerticalSpacing(),
						AirportWidget( iconData: Icons.flight_land, title: Text('flying to'), airport: flightDetails.arrival, onPressed: () => _selectArrival(context) ),
						VerticalSpacing(),
					],
				),
			),
		);
	}
}

class AirportSearchDelegate extends SearchDelegate<Airport> {
	AirportSearchDelegate({@required this.airportLookup});
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
	const AirportSearchResultTile({@required this.airport, @required this.searchDelegate});
	
	final Airport airport;
	final SearchDelegate<Airport> searchDelegate;
	
	@override
	Widget build(BuildContext context) {
		final title = '${airport.airport_name} (${airport.airport_code})';
		// final title = '${airport.name} (${airport.iata})';
		final subtitle = '${airport.airport_city}, ${airport.airport_country}';
		// final subtitle = '${airport.city}, ${airport.country}';
		final ThemeData theme = Theme.of(context);
		return ListTile(
			dense: true,
			title: Text( title, style: theme.textTheme.body2, textAlign: TextAlign.start, ),
			subtitle: Text( subtitle, style: theme.textTheme.body1, textAlign: TextAlign.start, ),
			onTap: () => searchDelegate.close(context, airport),
		);
	}
}
