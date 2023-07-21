public class SpiceJetTokenResponseWrapper {
 // this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB,TMS_FlightScheduleBatch_Helper apex class.
	public String status;
	public Integer code;
	public String message;
	public Result result;

	public class User_role {
		public String role_name;
		public String system_type;
	}

	public class User_data {
		public String name;
		public String email;
		public String contact_number;
		public String user_address;
		public String code;
		public String country;
		public String city;
		public String created_at;
		public Integer role_id;
		public String warehouse_code;
		public String image_path;
		public String is_active;
		public String organization_name;
		public String customer_station;
		public String participation_type;
		public String latitude;
		public String longitude;
		public String state;
		public String postal_code;
		public String airport_code;
		public String type;
		public String default_password;
		public Integer parent_id;
		public String default_station;
		public Boolean validate_credit;
		public String users_profile_image;
	}

	public class Result {
		public String access_token;
		public String token_type;
		public Integer expires_in;
		public User_data user_data;
		public User_role user_role;
	}

	
	public static SpiceJetTokenResponseWrapper parse(String json) {
		return (SpiceJetTokenResponseWrapper) System.JSON.deserialize(json,SpiceJetTokenResponseWrapper.class);
	}
}