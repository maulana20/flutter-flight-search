import '../model/airport.dart';

class AirportLookup {
	AirportLookup({this.airports});
	final List<Airport> airports;
	
	Airport searchIata(String code) {
		return airports.firstWhere((airport) => airport.airport_code == code);
	}
	
	List<Airport> searchString(String string) {
		string = string.toLowerCase();
		
		// final matching = airports.where((airport) { return airport.airport_code.toLowerCase() == string || airport.airport_name.toLowerCase() == string || airport.airport_city.toLowerCase() == string || airport.airport_country.toLowerCase() == string; }).toList();
		final matching = airports.where((airport) { return airport.airport_code.toLowerCase() == string || airport.airport_name.toLowerCase() == string || airport.airport_country.toLowerCase() == string; }).toList();
		
		if (matching.length > 0)  return matching;
		
		// return airports.where((airport) { return airport.airport_code.toLowerCase().contains(string) || airport.airport_name.toLowerCase().contains(string) || airport.airport_city.toLowerCase().contains(string) || airport.airport_country.toLowerCase().contains(string); }).toList();
		return airports.where((airport) { return airport.airport_code.toLowerCase().contains(string) || airport.airport_name.toLowerCase().contains(string) || airport.airport_country.toLowerCase().contains(string); }).toList();
	}
}
