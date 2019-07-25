import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

import 'blocs/flight_details_bloc.dart';
import '../../model/schedule.dart';

class FlightScheduleScreen extends StatelessWidget {
	FlightScheduleScreen({ this.flightDetails, this.schedules });
	
	final FlightDetails flightDetails;
	List<Schedule> schedules;
	
	@override
	Widget build(BuildContext context) {
		int count_pax = flightDetails.adult + (flightDetails.child != null ? flightDetails.child : 0);
		
		return MaterialApp(
			title: 'Pilih Jadwal',
			home: Scaffold(
				appBar: AppBar(
					leading: IconButton(
						icon: Icon(Icons.arrow_back),
						onPressed: () { Navigator.pop(context); },
					),
					title: Column(
						mainAxisSize: MainAxisSize.min,
						// mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Row(
								children: [
									Text(flightDetails.from_code, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
									SizedBox(width: 5.0),
									Icon(Icons.arrow_forward, size: 10.0),
									SizedBox(width: 5.0),
									Text(flightDetails.to_code, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
								],
							),
							Row(
								children: [
									Text(flightDetails.date, style: TextStyle(fontSize: 12.0)),
									SizedBox(width: 5.0),
									Icon(Icons.grade, size: 8.0),
									SizedBox(width: 5.0),
									Text('${count_pax} pax', style: TextStyle(fontSize: 12.0)),
								],
							),
						]
					),
				),
				body: ListView.builder(
					itemCount: schedules.length,
					itemBuilder: (context, index) {
						return FlightScheduleTile(schedule: schedules[index]);
					},
				),
			)
		); 
	}
}

class FlightScheduleTile extends StatelessWidget {
	FlightScheduleTile({ this.schedule });
	
	final Schedule schedule;
	
	@override
	Widget build(BuildContext context) {
		MoneyFormatterOutput total = FlutterMoneyFormatter(amount: schedule.total.toDouble()).output;
		
		return Card(
			child: Padding(
				padding: EdgeInsets.all(8.0),
				child: ListTile(
					title: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_flight(schedule.flightvendor.split('##')[0], schedule.flight.split('##')[0]),
									SizedBox(height: 4.0),
									_schedule(schedule.route.split('##')[0], schedule.str_time.split('##')[0]),
									SizedBox(height: 10.0),
									if (schedule.flightvendor.split('##').length > 1) _flight(schedule.flightvendor.split('##')[1], schedule.flight.split('##')[1]),
									if (schedule.flightvendor.split('##').length > 1) SizedBox(height: 4.0),
									if (schedule.flightvendor.split('##').length > 1) _schedule(schedule.route.split('##')[1], schedule.str_time.split('##')[1]),
									if (schedule.flightvendor.split('##').length > 1) SizedBox(height: 10.0),
								],
							),
							Row( children: [Text(total.withoutFractionDigits, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)), ], ),
						],
					),
					onTap: () => print(schedule.flightvendor),
				),
			),
		);
	}
	
	Row _flight(String vendor, String flight) {
		return Row( children: [ Text(vendor, style: TextStyle(fontSize: 12.0)), SizedBox(width: 5.0), Icon(Icons.flight, size: 12.0), SizedBox(width: 5.0), Text(flight, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)), ], );
	}
	
	Row _schedule(String route, String time) {
		return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Icon(Icons.calendar_today, size: 12.0), SizedBox(width: 5.0), _detail(route.split('-')[0], time.split(' ')[0]), SizedBox(width: 12.0), _detail(route.split('-')[1], time.split(' ')[1])]);
	}
	
	Row _detail(String city, String hour) {
		return Row(children: [Text(city, style: TextStyle(fontSize: 12.0)), SizedBox(width: 3.0), Text(hour, style: TextStyle(fontSize: 10.0))]);
	}
}
