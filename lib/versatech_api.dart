import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import 'model/isonlogin.dart';
import 'model/address.dart';
import 'model/airport.dart';
import 'model/schedule.dart';

import 'api/session.dart';

void main() async {
	final JsonDecoder _decoder = new JsonDecoder();
	
	IsOnLogin _isonlogin;
	Address _address;
	
	List<Airport> _airports = new List();
	List<Schedule> _schedules = new List();
	
	Session session = new Session();
	
	Future login() async {
		final response = await session.post('https://atris.versatiket.co.id/api/admin', body: {'user': 'user', 'password': 'pass'});
		
		return response;
	}
	
	Future ajaxresetlogin() async {
		final response = await session.post('https://atris.versatiket.co.id/api/admin/ajaxresetlogin', body: {'is_agree': 'true'});
		
		return response;
	}
	
	Future<IsOnLogin> isonlogin() async {
		final response = await session.get('https://atris.versatiket.co.id/api/admin/isonlogin');
		
		_isonlogin = IsOnLogin.fromJson(response['content']);
	}
	
	Future profile() async {
		final response = await session.get('https://atris.versatiket.co.id/api/user/profile');
		
		_address = Address.fromJson(response['content']['address']);
	}
	
	Future<Airport> airport() async {
		final response = await rootBundle.loadString('assets/data/airport_world_wide.json');
		
		var airport = json.decode(response).map<Airport>((json) => Airport.fromJson(json)).toList();
		
		_airports.clear();
		_airports.addAll(airport);
	}
	
	Future logout() async {
		final response = await session.get('https://atris.versatiket.co.id/api/admin/logout');
		
		return response;
	}
	
	Future<Schedule> iataLowFare() async {
		final response = await session.post('https://atris.versatiket.co.id/api/bookinginternational/internationalh2hlowfare', body: {'adult': '1', 'child': '0', 'infant': '0', 'from_code': 'CGK', 'to_code': 'SIN', 'from_date': '2019-08-10', 'to_date': '2019-08-10', 'trip_type': 'oneway', 'airlinecode': ''});
		
		var schedule = response['content']['list'].map<Schedule>((json) => Schedule.fromJson(json)).toList();
		
		_schedules.clear();
		_schedules.addAll(schedule);
	}
	
	var login_data = await login();
	if (login_data['status'] == 'inuse') await ajaxresetlogin();
	
	await isonlogin();
	print('info:' + _isonlogin.info + ' ' + 'url_login:' + _isonlogin.url_login + ' ' + 'url_logout:' + _isonlogin.url_logout);
	
	await profile();
	print(_address.address_city);
	
	/* await airport();
	for (final data in _airports) {
		print(data.airport_code);
	} */
	
	await iataLowFare();
	for (final data in _schedules) {
		print(data.flight);
	}
	
	await logout();
}
