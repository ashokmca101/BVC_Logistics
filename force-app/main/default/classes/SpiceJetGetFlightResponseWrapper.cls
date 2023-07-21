public class SpiceJetGetFlightResponseWrapper {
 // this class is used as wrapper class as well this class deserialize the JOSN response body and used in TMS_FlightScheduleBatch_Helper apex class.
	public class Result {
		public String id;
		public String flight_id;
		public Date departure_date;
		public String flight_no;
		public String registration_no;
		public String aircraft_type;
		public String source;
		public String destination;
		public String operational_status;
		public String dep_bay_no;
		public String arr_bay_no;
		public String atd;
		public String ata;
		public String etd;
		public String eta;
		public String std;
		public String sta;
		public String manufacturer;
		public String delay_code;
		public String delay_reason;
		public String dep_delay;
		public String is_active;
		public String cms_value;
		public String dom;
		public String created_at;
		public String updated_at;
	}

	public String status;
	public Integer code;
	public String message;
	public List<Result> result;

	
	public static SpiceJetGetFlightResponseWrapper parse(String json) {
		return (SpiceJetGetFlightResponseWrapper) System.JSON.deserialize(json, SpiceJetGetFlightResponseWrapper.class);
	}
}