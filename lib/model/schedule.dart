class Schedule extends Object {
	String flight;
	String flightvendor;
	String route;
	String date_arrive;
	String date_depart;
	String str_time;
	int total;
	
	Schedule({this.flight, this.flightvendor, this.route, this.date_arrive, this.date_depart, this.str_time, this.total});
	
	factory Schedule.fromJson(Map<String, dynamic> json) {
		return Schedule(
			flight: json['flight'],
			flightvendor: json['flightvendor'],
			route: json['route'],
			date_arrive: json['date_arrive'],
			date_depart: json['date_depart'],
			str_time: json['str_time'],
			total: json['total'],
		);
	}
}
