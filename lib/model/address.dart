class Address extends Object {
	String address_city;
	String address_country;
	String address_detail;
	String address_postcode;
	String address_state;
	
	Address({this.address_city, this.address_country, this.address_detail, this.address_postcode, this.address_state});
	
	factory Address.fromJson(Map<String, dynamic> json) {
		return Address(
			address_city: json['address_city'],
			address_country: json['address_country'],
			address_detail: json['address_detail'],
			address_postcode: json['address_postcode'],
			address_state: json['address_state'],
		);
	}
}
