public class SpiceJet_CreateAWBresponse {

   // this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_createAWB apex class.
	public String status;
	public Integer code;
	public String message;
	public Result result;

	public class Result {
		public Integer id;
		public String awb_number;
		public String booking_type;
		public Integer current_status;
		public Boolean mappingrequired;
	}

	
	public static SpiceJet_CreateAWBresponse parse(String json) {
		return (SpiceJet_CreateAWBresponse) System.JSON.deserialize(json, SpiceJet_CreateAWBresponse.class);
	}
}