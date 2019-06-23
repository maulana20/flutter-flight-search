class IsOnLogin extends Object {
	String info;
	String url_login;
	String url_logout;
	
	IsOnLogin({ this.info, this.url_login, this.url_logout });
	
	factory IsOnLogin.fromJson(Map<String, dynamic> json) {
		return IsOnLogin(
			info: json['info'],
			url_login: json['url_login'],
			url_logout: json['url_logout'],
		);
	}
}
