public class SpicejetTrackAWBwrapper {
 // This is wrapper class and is also used to deserialize response adn used in Track_AWB_SpiceJetHelper apex class.
	public String status;
	public Integer code;
	public String message;
	public Result result;

	public class Task_tracker {
		public Integer status_id;
		public String status_detail;
		public String airport_code;
		public String flight_details;
		public String event_date_time;
		public String weight;
		public List<String> bag_list;
	}
// this method is used to create linehaul tracking record in Track_AWB_SpiceJetHelper  apex class
	public class Result {
		public List<Task_tracker> Task_tracker;
	}

// deserialization method
	public static SpicejetTrackAWBwrapper parse(String json) {
		return (SpicejetTrackAWBwrapper) System.JSON.deserialize(json, SpicejetTrackAWBwrapper.class);
	}
}