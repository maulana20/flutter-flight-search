import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Session {
	final JsonDecoder _decoder = new JsonDecoder();
	Map<String, String> headers = {};
	
	Future<Map> get(String url) async {
		http.Response response = await http.get(url, headers: headers);
		print('Response ' + url.split('/')[4] + (url.split('/').length > 5 ? '-' + url.split('/')[5] : '') + ' : ' + response.body);
		
		updateCookie(response);
		
		if (response.statusCode == 200) {
			return _decoder.convert(response.body);
		} else {
			throw Exception('Connection error !');
		}
	}
	
	Future<Map> post(String url, {Map<String, String> body}) async {
		http.Response response = await http.post(url, body: body, headers: headers);
		print('Response ' + url.split('/')[4] + (url.split('/').length > 5 ? '-' + url.split('/')[5] : '') + ' : ' + response.body);
		
		updateCookie(response);
		
		if (response.statusCode == 200) {
			return _decoder.convert(response.body);
		} else {
			throw Exception('Connection error !');
		}
	}
	
	void updateCookie(http.Response response) {
		var cookie = response.headers['set-cookie'];
		
		cookie = cookie.substring(cookie.indexOf('ATRISSESSION'));
		cookie = cookie.substring(0, cookie.indexOf(';')) + ';';
		
		headers['cookie'] = cookie;
	}
}
