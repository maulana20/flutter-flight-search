import 'package:flutter/material.dart';

import 'blocs/flight_details_bloc.dart';
import '../../model/schedule.dart';

class FlightScheduleScreen extends StatelessWidget {
	FlightScheduleScreen({ this.flightDetails, this.schedules });
	
	final FlightDetails flightDetails;
	List<Schedule> schedules;
	
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Pilih Jadwal',
			home: Scaffold(
				appBar: AppBar(
					leading: IconButton(
						icon: Icon(Icons.arrow_back),
						onPressed: () { Navigator.pop(context); },
					),
					title: Center(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(flightDetails.from_code, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
										Icon(Icons.arrow_forward, size: 14.0),
										Text(flightDetails.to_code, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
									],
								),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(flightDetails.date, style: TextStyle(fontSize: 12.0)),
										Icon(Icons.grade, size: 10.0),
										Text(flightDetails.adult.toString() + ' pax', style: TextStyle(fontSize: 12.0)),
									],
								),
							]
						),
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
		return Card(
			child: ListTile(
				title: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Row( children: [ Text('${schedule.flightvendor.split('##')[0]} '), Icon(Icons.flight, size: 12.0), Text(' ${schedule.flight.split('##')[0]}'), ], ),
						SizedBox(height: 4.0),
						Row( children: [ Icon(Icons.calendar_today, size: 12.0), Text(' ${schedule.str_time.split('##')[0]}', style: TextStyle(fontSize: 12.0)), ], ),
						SizedBox(height: 8.0),
						if (schedule.flightvendor.split('##').length > 1) Row( children: [ Text('${schedule.flightvendor.split('##')[1]} '), Icon(Icons.flight, size: 12.0), Text(' ${schedule.flight.split('##')[1]}')], ),
						if (schedule.flightvendor.split('##').length > 1) SizedBox(height: 4.0),
						if (schedule.str_time.split('##').length > 1) Row( children: [ Icon(Icons.calendar_today, size: 12.0), Text(' ${schedule.str_time.split('##')[1]}', style: TextStyle(fontSize: 12.0)), ], ),
						if (schedule.str_time.split('##').length > 1) SizedBox(height: 8.0),
					],
				),
				// title: Text('${schedule.flight} ${schedule.flightvendor} ${schedule.route} ${schedule.date_arrive} ${schedule.date_depart} ${schedule.str_time}'),
				// onTap: () => Navigator.pop(context),
			),
		);
	}
}
