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
	
	void updateWith({ Airport departure, Airport arrival, from_code, to_code }) {
		Flight newValue = _flightSubject.value.copyWith(
			departure: departure,
			arrival: arrival,
			from_code: from_code,
			to_code: to_code,
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
	
	Flight copyWith({ Airport departure, Airport arrival, from_code, to_code }) {
		FlightDetails flightDetails = details.copyWith( departure: departure, arrival: arrival, from_code: from_code, to_code: to_code );
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
	
	FlightDetails({ this.departure, this.arrival, this.from_code, this.to_code });
	FlightDetails copyWith({ Airport departure, Airport arrival, from_code, to_code }) {
		return FlightDetails(
			departure: departure ?? this.departure,
			arrival: arrival ?? this.arrival,
			from_code: from_code ?? this.from_code,
			to_code: to_code ?? this.to_code,
		);
	}
}
