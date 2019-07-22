import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'flight/blocs/flight_details_bloc.dart';
import 'flight/flight_detail_screen.dart';
import '../model/airport.dart';
import '../model/schedule.dart';
import '../api/airport_lookup.dart';
import '../api/versatiket_api.dart';

class FlightScreen extends StatefulWidget {
	FlightScreen({ this.airportLookup });
	
	final AirportLookup airportLookup;
	
	@override
	_FlightScreenState createState() => _FlightScreenState(airportLookup: airportLookup);
}

class _FlightScreenState extends State<FlightScreen> {
	_FlightScreenState({ this.airportLookup });
	
	final AirportLookup airportLookup;
	final String title = 'Flutter Flight';
	
	VersatiketApi _versaApi;
	List<Schedule> schedules;
	
	bool _isLoading = false;
	
	@override
	void initState() {
		super.initState();
		_versaApi = VersatiketApi();
	}
	
	Future<void> _alert(BuildContext context, String info) {
		return showDialog<void>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text('Warning !'),
					content: Text(info),
					actions: <Widget>[
						FlatButton(
							child: Text('Ok'),
							onPressed: () {
							  Navigator.of(context).pop();
							},
						),
					],
				);
			},
		);
	}
	
	Future _process(FlightDetails details) async {
		if (details.from_code.isEmpty) {
			_alert(context, 'tidak ada pilih untuk keberangkatan');
		} else if (details.to_code.isEmpty) {
			_alert(context, 'tidak ada pilih untuk tiba');
		} else if (details.date.isEmpty) {
			_alert(context, 'tanggal harus di isi');
		} else if (details.adult == 0 || details.adult == null) {
			_alert(context, 'penumpang dewasa tidak boleh kosong');
		} else {
			setState(() { _isLoading = true; } );
			
			await _versaApi.start();
			
			// schedules = await _versaApi.search(details);
			var res = await _versaApi.searchPost(details);
			if (res['status'] == 'timeout') { 
				_alert(context, res['message']);
			} else if (res['status'] == 'failed') {
				_alert(context, res['content']['reason']);
			} else {
				schedules = res['content']['list'].map<Schedule>((json) => Schedule.fromJson(json)).toList();
				Navigator.push(context, MaterialPageRoute(builder: (context) => FlightScheduleScreen(flightDetails: details, schedules: schedules)));
			}
			
			await _versaApi.logout();
			setState(() { _isLoading = false; } );
		}
	}
	
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
										child: _isLoading ? SizedBox(child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 10.0, width: 10.0 ) : Text("SEARCH", style: TextStyle(color: Colors.white)),
										color: Colors.brown,
										onPressed: () => _isLoading ? null : _process(snapshot.data.details),
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

class DateWidget extends StatefulWidget {
	DateWidget({ this.flightDetailsBloc });
	
	final FlightDetailsBloc flightDetailsBloc;
	
	@override
	_DateWidgetState createState() => _DateWidgetState(flightDetailsBloc: flightDetailsBloc);
}

class _DateWidgetState extends State<DateWidget> {
	_DateWidgetState({ this.flightDetailsBloc });
	
	final FlightDetailsBloc flightDetailsBloc;
	final _date = TextEditingController();
	
	Future _select() async {
		DateTime picked = await showDatePicker(
			context: context,
			initialDate: new DateTime.now(),
			firstDate: new DateTime(2016),
			lastDate: new DateTime(2030)
		);
		if(picked != null) {
			setState(() {
				var dd = DateFormat('yyyy-MM-dd').format(picked);
				
				_date.text = dd;
				flightDetailsBloc.updateWith(date: dd);
				print('Selected date: ' + dd);
			});
		}
	}
	
	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () { _select(); },
			child: Padding(
				padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
				child: Row(
					mainAxisSize: MainAxisSize.max,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						Icon(Icons.calendar_today),
						SizedBox(width: 16.0),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									VerticalSpacing(height: 4.0),
									IgnorePointer(
										child: TextFormField(
											controller: _date,
											decoration: new InputDecoration(hintText: 'yyyy-mm-dd'),
											maxLength: 10,
											enabled: false,
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

class PassengerWidget extends StatefulWidget {
	PassengerWidget({ this.flightDetailsBloc });
	
	final FlightDetailsBloc flightDetailsBloc;
	
	@override
	_PassengerWidgetState createState() => _PassengerWidgetState(flightDetailsBloc: flightDetailsBloc);
}

class _PassengerWidgetState extends State<PassengerWidget> {
	_PassengerWidgetState({ this.flightDetailsBloc });
	
	final FlightDetailsBloc flightDetailsBloc;
	
	int _adult = 0;
	int _child = 0;
	int _infant = 0;
	
	@override
	Widget build(BuildContext context) {
		return Container(
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				children: <Widget>[
					Column(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text('Adult'),
							IconButton(icon: new Icon(Icons.add), onPressed: () { setState(() { _adult < 9 ? _adult++ : Container(); flightDetailsBloc.updateWith(adult: _adult); }); }),
							Text(_adult.toString()),
							IconButton(icon: new Icon(Icons.remove), onPressed: () { setState(() { _adult > 0 ? _adult-- : Container(); flightDetailsBloc.updateWith(adult: _adult); }); }),
						],
					),
					Column(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text('Child'),
							IconButton(icon: new Icon(Icons.add), onPressed: () { setState(() { _child < 9 ? _child++ : Container(); flightDetailsBloc.updateWith(child: _child); }); }),
							Text(_child.toString()),
							IconButton(icon: new Icon(Icons.remove), onPressed: () { setState(() { _child > 0 ? _child-- : Container(); flightDetailsBloc.updateWith(child: _child); }); }),
						],
					),
					Column(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text('Infant'),
							IconButton(icon: new Icon(Icons.add), onPressed: () { setState(() { _infant < 9 ? _infant++ : Container(); flightDetailsBloc.updateWith(infant: _infant); }); }),
							Text(_infant.toString()),
							IconButton(icon: new Icon(Icons.remove), onPressed: () { setState(() { _infant > 0 ? _infant-- : Container(); }); flightDetailsBloc.updateWith(infant: _infant); }),
						],
					),
				],
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
						// VerticalSpacing(),
						DateWidget(flightDetailsBloc: flightDetailsBloc),
						VerticalSpacing(),
						PassengerWidget(flightDetailsBloc: flightDetailsBloc),
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
		// if (query.length < 3) return Container();
		
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
