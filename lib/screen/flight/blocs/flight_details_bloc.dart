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
	
	void updateWith({ Airport departure, Airport arrival, FlightClass flightClass, FlightType flightType, }) {
		Flight newValue = _flightSubject.value.copyWith(
			departure: departure,
			arrival: arrival,
			flightClass: flightClass,
			flightType: flightType,
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
	
	Flight copyWith({ Airport departure, Airport arrival, FlightClass flightClass, FlightType flightType, }) {
		FlightDetails flightDetails = details.copyWith( departure: departure, arrival: arrival, flightClass: flightClass, flightType: flightType, );
		return Flight(
			details: flightDetails
		);
	}
}

class FlightDetails {
	final Airport departure;
	final Airport arrival;
	final FlightClass flightClass;
	final FlightType flightType;
	
	FlightDetails({ this.departure, this.arrival, this.flightClass = FlightClass.economy, this.flightType = FlightType.oneWay });
	FlightDetails copyWith({ Airport departure, Airport arrival, FlightClass flightClass, FlightType flightType }) {
		return FlightDetails(
			departure: departure ?? this.departure,
			arrival: arrival ?? this.arrival,
			flightClass: flightClass ?? this.flightClass,
			flightType: flightType ?? this.flightType,
		);
	}
}

enum FlightType {
	oneWay, twoWays
}

enum FlightClass {
	economy, business, first
}
