import 'package:flutter/foundation.dart';

class Airport extends Object {
	String airport_city;
	String airport_code;
	String airport_continent;
	String airport_country;
	String airport_name;
	
	Airport({this.airport_city, this.airport_code, this.airport_continent, this.airport_country, this.airport_name});
	
	factory Airport.fromJson(Map<String, dynamic> json) {
		return Airport(
			airport_city: json['airport_city'],
			airport_code: json['airport_code'],
			airport_continent: json['airport_continent'],
			airport_country: json['airport_country'],
			airport_name: json['airport_name'],
		);
	}
}
