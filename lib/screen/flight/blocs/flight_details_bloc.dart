import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../../model/airport.dart';

class FlightDetailsBloc {
	BehaviorSubject _flightSubject = BehaviorSubject<Flight>(
		seedValue: Flight.initialData(),
	);
	
	Stream<Flight> get flightStream => _flightSubject.controller.stream;
	
	void updateWith({ Airport departure, Airport arrival, from_code, to_code, date, adult, child, infant }) {
		Flight newValue = _flightSubject.value.copyWith(
			departure: departure,
			arrival: arrival,
			from_code: from_code,
			to_code: to_code,
			date: date,
			adult: adult,
			child: child,
			infant: infant,
		);
		_flightSubject.add(newValue);
	}
	
	dispose() {
		_flightSubject.close();
	}
}

class Flight {
	Flight({@required this.details});
	final FlightDetails details;
	
	factory Flight.initialData() {
		return Flight(
			details: FlightDetails()
		);
	}
	
	Flight copyWith({ Airport departure, Airport arrival, from_code, to_code, date, adult, child, infant }) {
		FlightDetails flightDetails = details.copyWith( departure: departure, arrival: arrival, from_code: from_code, to_code: to_code, date: date, adult: adult, child: child, infant: infant );
		return Flight(
			details: flightDetails
		);
	}
}

class FlightDetails {
	final Airport departure;
	final Airport arrival;
	final String from_code;
	final String to_code;
	final String date;
	final int adult;
	final int child;
	final int infant;
	
	FlightDetails({ this.departure, this.arrival, this.from_code, this.to_code, this.date, this.adult, this.child, this.infant });
	FlightDetails copyWith({ Airport departure, Airport arrival, from_code, to_code, date, adult, child, infant }) {
		return FlightDetails(
			departure: departure ?? this.departure,
			arrival: arrival ?? this.arrival,
			from_code: from_code ?? this.from_code,
			to_code: to_code ?? this.to_code,
			date: date ?? this.date,
			adult: adult ?? this.adult,
			child: child ?? this.child,
			infant: infant ?? this.infant,
		);
	}
}
