import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

import 'package:http/http.dart' as http;

import 'session.dart';
import '../model/schedule.dart';
import '../screen/flight/blocs/flight_details_bloc.dart';

class VersatiketApi {
	final String url = 'url';
	final String username = 'user';
	final String password = 'pass';
	
	Session session = new Session();
	
	Future start() async {
		final isonlogin_data = await isonlogin();
		if (isonlogin_data['status'] == 'failed') {
			final login_data = await login();
			if (login_data['status'] == 'inuse') await ajaxresetlogin();
		}
	}
	
	Future login() async {
		return await session.post(url + '/api/admin', body: {'user': username, 'password': password});
	}
	
	Future ajaxresetlogin() async {
		return await session.post(url + '/api/admin/ajaxresetlogin', body: {'is_agree': 'true'});
	}
	
	Future logout() async {
		return await session.get(url + '/api/admin/logout');
	}
	
	// Future profile() async {
	//	final response = await session.get(url + '/api/user/profile');
	//	return Address.fromJson(response['content']['address']);
	// }
	
	Future isonlogin() async {
		return await session.get(url + '/api/admin/isonlogin');
	}
	
	Future<List<Schedule>> search(FlightDetails details) async {
		final response = await session.post(url + '/api/bookinginternational/internationalh2hlowfare', body: {'adult': details.adult.toString(), 'child': details.child.toString(), 'infant': details.infant.toString(), 'from_code': details.from_code, 'to_code': details.to_code, 'from_date': details.date, 'to_date': details.date, 'trip_type': 'oneway', 'airlinecode': ''});
		return response['content']['list'].map<Schedule>((json) => Schedule.fromJson(json)).toList();
	}
	
	Future searchPost(FlightDetails details) async {
		return await session.post(url + '/api/bookinginternational/internationalh2hlowfare', body: {'adult': details.adult.toString(), 'child': details.child.toString(), 'infant': details.infant.toString(), 'from_code': details.from_code, 'to_code': details.to_code, 'from_date': details.date, 'to_date': details.date, 'trip_type': 'oneway', 'airlinecode': ''});
	}
}
